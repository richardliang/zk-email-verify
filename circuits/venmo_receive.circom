pragma circom 2.1.5;

include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "./helpers/sha.circom";
include "./helpers/rsa.circom";
include "./helpers/base64.circom";
include "./helpers/extract.circom";

include "./regexes/from_regex.circom";
include "./regexes/tofrom_domain_regex.circom";
include "./regexes/body_hash_regex.circom";
include "./regexes/venmo_receive_id.circom";
include "./regexes/venmo_timestamp.circom";

// Here, n and k are the biginteger parameters for RSA
// This is because the number is chunked into k pack_size of n bits each
// Max header bytes shouldn't need to be changed much per email,
// but the max mody bytes may need to be changed to be larger if the email has a lot of i.e. HTML formatting
// TODO: split into header and body
template VenmoReceiveEmail(max_header_bytes, max_body_bytes, n, k, pack_size) {
    assert(max_header_bytes % 64 == 0);
    assert(max_body_bytes % 64 == 0);
    assert(n * k > 1024); // constraints for 2048 bit RSA
    assert(n < (255 \ 2)); // we want a multiplication to fit into a circom signal

    signal input in_padded[max_header_bytes]; // prehashed email data, includes up to 512 + 64? bytes of padding pre SHA256, and padded with lots of 0s at end after the length
    signal input modulus[k]; // rsa pubkey, verified with smart contract + DNSSEC proof. split up into k parts of n bits each.
    signal input signature[k]; // rsa signature. split up into k parts of n bits each.
    signal input in_len_padded_bytes; // length of in email data including the padding, which will inform the sha256 block length


    // Base 64 body hash variables
    var LEN_SHA_B64 = 44;     // ceil(32 / 3) * 4, due to base64 encoding.
    signal input body_hash_idx;

    // SHA HEADER: 506,670 constraints
    // This calculates the SHA256 hash of the header, which is the "base_msg" that is RSA signed.
    // The header signs the fields in the "h=Date:From:To:Subject:MIME-Version:Content-Type:Message-ID;"
    // section of the "DKIM-Signature:"" line, along with the body hash.
    // Note that nothing above the "DKIM-Signature:" line is signed.
    signal sha[256] <== Sha256Bytes(max_header_bytes)(in_padded, in_len_padded_bytes);
    var msg_len = (256 + n) \ n;

    component base_msg[msg_len];
    for (var i = 0; i < msg_len; i++) {
        base_msg[i] = Bits2Num(n);
    }
    for (var i = 0; i < 256; i++) {
        base_msg[i \ n].in[i % n] <== sha[255 - i];
    }
    for (var i = 256; i < n * msg_len; i++) {
        base_msg[i \ n].in[i % n] <== 0;
    }

    // VERIFY RSA SIGNATURE: 149,251 constraints
    // The fields that this signature actually signs are defined as the body and the values in the header
    component rsa = RSAVerify65537(n, k);
    for (var i = 0; i < msg_len; i++) {
        rsa.base_message[i] <== base_msg[i].out;
    }
    for (var i = msg_len; i < k; i++) {
        rsa.base_message[i] <== 0;
    }
    rsa.modulus <== modulus;
    rsa.signature <== signature;

    // BODY HASH REGEX: 617,597 constraints
    // This extracts the body hash from the header (i.e. the part after bh= within the DKIM-signature section)
    // which is used to verify the body text matches this signed hash + the signature verifies this hash is legit
    signal (bh_regex_out, bh_reveal[max_header_bytes]) <== BodyHashRegex(max_header_bytes)(in_padded);
    bh_regex_out === 1;
    signal shifted_bh_out[LEN_SHA_B64] <== VarShiftLeft(max_header_bytes, LEN_SHA_B64)(bh_reveal, body_hash_idx);
    // log(body_hash_regex.out);


    // SHA BODY: 760,142 constraints

    // Precomputed sha vars for big body hashing
    // Next 3 signals are for decreasing SHA constraints for parsing out information from the in-body text
    // The precomputed_sha value is the Merkle-Damgard state of our SHA hash uptil our first regex match
    // This allows us to save a ton of SHA constraints by only hashing the relevant part of the body
    // It doesn't have an impact on security since a user must have known the pre-image of a signed message to be able to fake it
    // The lower two body signals describe the suffix of the body that we care about
    // The part before these signals, a significant prefix of the body, has been pre-hashed into precomputed_sha.
    signal input precomputed_sha[32];
    signal input in_body_padded[max_body_bytes];
    signal input in_body_len_padded_bytes;

    // This verifies that the hash of the body, when calculated from the precomputed part forwards,
    // actually matches the hash in the header
    signal sha_body_out[256] <== Sha256BytesPartial(max_body_bytes)(in_body_padded, in_body_len_padded_bytes, precomputed_sha);
    signal sha_b64_out[32] <== Base64Decode(32)(shifted_bh_out);

    // When we convert the manually hashed email sha_body into bytes, it matches the
    // base64 decoding of the final hash state that the signature signs (sha_b64)
    component sha_body_bytes[32];
    for (var i = 0; i < 32; i++) {
        sha_body_bytes[i] = Bits2Num(8);
        for (var j = 0; j < 8; j++) {
            sha_body_bytes[i].in[7 - j] <== sha_body_out[i * 8 + j];
        }
        sha_body_bytes[i].out === sha_b64_out[i];
    }


    //
    // CUSTOM REGEXES
    //

    // TIMESTAMP REGEX: [x]
    var max_email_timestamp_len = 30;
    var max_email_timestamp_packed_bytes = count_packed(max_email_timestamp_len, pack_size);
    assert(max_email_timestamp_packed_bytes < max_header_bytes);

    signal input email_timestamp_idx;
    signal output reveal_email_timestamp_packed[max_email_timestamp_packed_bytes]; // packed into 7-bytes. TODO: make this rotate to take up even less space

    signal timestamp_regex_out, timestamp_regex_reveal[max_header_bytes];
    (timestamp_regex_out, timestamp_regex_reveal) <== VenmoTimestampRegex(max_header_bytes)(in_padded);
    timestamp_regex_out === 1;

    // PACKING: 16,800 constraints (Total: [x])
    reveal_email_timestamp_packed <== ShiftAndPack(max_header_bytes, max_email_timestamp_len, pack_size)(timestamp_regex_reveal, email_timestamp_idx);
    
    
    // VENMO RECEIVE ONRAMPER ID REGEX: [x]
    var max_venmo_receive_len = 21;
    var max_venmo_receive_packed_bytes = count_packed(max_venmo_receive_len, pack_size); // ceil(max_num_bytes / 7)
    
    signal input venmo_receive_id_idx;
    signal output reveal_venmo_receive_packed[max_venmo_receive_packed_bytes];

    signal (venmo_receive_regex_out, venmo_receive_regex_reveal[max_body_bytes]) <== VenmoReceiveId(max_body_bytes)(in_body_padded);
    signal is_found_venmo_receive <== IsZero()(venmo_receive_regex_out);
    is_found_venmo_receive === 0;

    // PACKING: 16,800 constraints (Total: [x])
    reveal_venmo_receive_packed <== ShiftAndPack(max_body_bytes, max_venmo_receive_len, pack_size)(venmo_receive_regex_reveal, venmo_receive_id_idx);

    // Hash onramper ID
    component hash = Poseidon(max_venmo_receive_packed_bytes);
    assert(max_venmo_receive_packed_bytes < 16);
    for (var i = 0; i < max_venmo_receive_packed_bytes; i++) {
        hash.inputs[i] <== reveal_venmo_receive_packed[i];
    }
    signal output packed_onramper_id_hashed <== hash.out;
    log("Hash of packed Venmo Onramper ID", packed_onramper_id_hashed);


    // Nullifier
    // Packed SHA256 hash of the email header and body hash (the part that is signed upon)
    signal output nullifier[msg_len];
    for (var i = 0; i < msg_len; i++) {
        nullifier[i] <== base_msg[i].out;
    }

    // The following signals do not take part in any computation, but tie the proof to a specific order_id & claim_id to prevent replay attacks and frontrunning.
    // https://geometry.xyz/notebook/groth16-malleability
    signal input order_id;
    signal input claim_id;
    signal order_id_squared;
    signal claim_id_squared;
    order_id_squared <== order_id * order_id;
    claim_id_squared <== claim_id * claim_id;
}

// In circom, all output signals of the main component are public (and cannot be made private), the input signals of the main component are private if not stated otherwise using the keyword public as above. The rest of signals are all private and cannot be made public.
// This makes modulus and reveal_twitter_packed public. hash(signature) can optionally be made public, but is not recommended since it allows the mailserver to trace who the offender is.

// Args:
// * max_header_bytes = 1024 is the max number of bytes in the header
// * max_body_bytes = 6400 is the max number of bytes in the body after precomputed slice
// * n = 121 is the number of bits in each chunk of the modulus (RSA parameter)
// * k = 9 is the number of chunks in the modulus (RSA parameter)
// * pack_size = 7 is the number of bytes that can fit into a 255ish bit signal (can increase later)
component main { public [ modulus, order_id, claim_id ] } = VenmoReceiveEmail(1024, 6400, 121, 9, 7);
