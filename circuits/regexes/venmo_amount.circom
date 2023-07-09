pragma circom 2.1.5;

include "./regex_helpers.circom";


template VenmoAmountRegex (msg_bytes) {
    signal input msg[msg_bytes];
    signal output out;

    var num_bytes = msg_bytes;
    signal in[num_bytes];
    for (var i = 0; i < msg_bytes; i++) {
        in[i] <== msg[i];
    }
	
    component eq[2][num_bytes];
    component lt[12][num_bytes];
    component and[10][num_bytes];
    component multi_or[3][num_bytes];
    signal states[num_bytes+1][4];

    for (var i = 0; i < num_bytes; i++) {
            states[i][0] <== 1;
    }
    for (var i = 1; i < 4; i++) {
            states[0][i] <== 0;
    }

    for (var i = 0; i < num_bytes; i++) {
        lt[0][i] = LessThan(8);
        lt[0][i].in[0] <== 64;
        lt[0][i].in[1] <== in[i];
        lt[1][i] = LessThan(8);
        lt[1][i].in[0] <== in[i];
        lt[1][i].in[1] <== 91;
        and[0][i] = AND();
        and[0][i].a <== lt[0][i].out;
        and[0][i].b <== lt[1][i].out;
        lt[2][i] = LessThan(8);
        lt[2][i].in[0] <== 96;
        lt[2][i].in[1] <== in[i];
        lt[3][i] = LessThan(8);
        lt[3][i].in[0] <== in[i];
        lt[3][i].in[1] <== 123;
        and[1][i] = AND();
        and[1][i].a <== lt[2][i].out;
        and[1][i].b <== lt[3][i].out;
        lt[4][i] = LessThan(8);
        lt[4][i].in[0] <== 47;
        lt[4][i].in[1] <== in[i];
        lt[5][i] = LessThan(8);
        lt[5][i].in[0] <== in[i];
        lt[5][i].in[1] <== 58;
        and[2][i] = AND();
        and[2][i].a <== lt[4][i].out;
        and[2][i].b <== lt[5][i].out;
        and[3][i] = AND();
        and[3][i].a <== states[i][1];
        multi_or[0][i] = MultiOR(3);
        multi_or[0][i].in[0] <== and[0][i].out;
        multi_or[0][i].in[1] <== and[1][i].out;
        multi_or[0][i].in[2] <== and[2][i].out;
        and[3][i].b <== multi_or[0][i].out;
        lt[6][i] = LessThan(8);
        lt[6][i].in[0] <== 64;
        lt[6][i].in[1] <== in[i];
        lt[7][i] = LessThan(8);
        lt[7][i].in[0] <== in[i];
        lt[7][i].in[1] <== 91;
        and[4][i] = AND();
        and[4][i].a <== lt[6][i].out;
        and[4][i].b <== lt[7][i].out;
        lt[8][i] = LessThan(8);
        lt[8][i].in[0] <== 96;
        lt[8][i].in[1] <== in[i];
        lt[9][i] = LessThan(8);
        lt[9][i].in[0] <== in[i];
        lt[9][i].in[1] <== 123;
        and[5][i] = AND();
        and[5][i].a <== lt[8][i].out;
        and[5][i].b <== lt[9][i].out;
        lt[10][i] = LessThan(8);
        lt[10][i].in[0] <== 47;
        lt[10][i].in[1] <== in[i];
        lt[11][i] = LessThan(8);
        lt[11][i].in[0] <== in[i];
        lt[11][i].in[1] <== 58;
        and[6][i] = AND();
        and[6][i].a <== lt[10][i].out;
        and[6][i].b <== lt[11][i].out;
        and[7][i] = AND();
        and[7][i].a <== states[i][2];
        multi_or[1][i] = MultiOR(3);
        multi_or[1][i].in[0] <== and[4][i].out;
        multi_or[1][i].in[1] <== and[5][i].out;
        multi_or[1][i].in[2] <== and[6][i].out;
        and[7][i].b <== multi_or[1][i].out;
        multi_or[2][i] = MultiOR(2);
        multi_or[2][i].in[0] <== and[3][i].out;
        multi_or[2][i].in[1] <== and[7][i].out;
        states[i+1][1] <== multi_or[2][i].out;
        
        // $
        eq[0][i] = IsEqual();
        eq[0][i].in[0] <== in[i];
        eq[0][i].in[1] <== 36;
        and[8][i] = AND();
        and[8][i].a <== states[i][0];
        and[8][i].b <== eq[0][i].out;
        states[i+1][2] <== and[8][i].out;
        
        // . (Doesn't work without this apparently!)
        eq[1][i] = IsEqual();
        eq[1][i].in[0] <== in[i];
        eq[1][i].in[1] <== 46;
        and[9][i] = AND();
        and[9][i].a <== states[i][1];
        and[9][i].b <== eq[1][i].out;
        states[i+1][3] <== and[9][i].out;
    }

    signal final_state_sum[num_bytes+1];
    final_state_sum[0] <== states[0][3];
    for (var i = 1; i <= num_bytes; i++) {
            final_state_sum[i] <== final_state_sum[i-1] + states[i][3];
    }
    out <== final_state_sum[num_bytes];

    // Vector that masks the email with mostly 0s, but reveals the regex string
    signal output reveal[num_bytes];
    for (var i = 0; i < num_bytes; i++) {
        reveal[i] <== in[i] * states[i+1][1];
    }
}