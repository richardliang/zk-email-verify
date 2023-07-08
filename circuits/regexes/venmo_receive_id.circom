pragma circom 2.1.5;

include "./regex_helpers.circom";

template VenmoReceiveId (msg_bytes) {
    signal input msg[msg_bytes];
    signal output out;

    var num_bytes = msg_bytes;
    signal in[num_bytes];
    for (var i = 0; i < msg_bytes; i++) {
        in[i] <== msg[i];
    }

    component eq[10][num_bytes];
    component lt[4][num_bytes];
    component and[14][num_bytes];
    component multi_or[1][num_bytes];
    signal states[num_bytes+1][12];

    for (var i = 0; i < num_bytes; i++) {
        states[i][0] <== 1;
    }
    for (var i = 1; i < 12; i++) {
        states[0][i] <== 0;
    }

    for (var i = 0; i < num_bytes; i++) {
        lt[0][i] = LessThan(8);
        lt[0][i].in[0] <== 47;
        lt[0][i].in[1] <== in[i];
        lt[1][i] = LessThan(8);
        lt[1][i].in[0] <== in[i];
        lt[1][i].in[1] <== 58;
        and[0][i] = AND();
        and[0][i].a <== lt[0][i].out;
        and[0][i].b <== lt[1][i].out;
        and[1][i] = AND();
        and[1][i].a <== states[i][1];
        and[1][i].b <== and[0][i].out;
        lt[2][i] = LessThan(8);
        lt[2][i].in[0] <== 47;
        lt[2][i].in[1] <== in[i];
        lt[3][i] = LessThan(8);
        lt[3][i].in[0] <== in[i];
        lt[3][i].in[1] <== 58;
        and[2][i] = AND();
        and[2][i].a <== lt[2][i].out;
        and[2][i].b <== lt[3][i].out;
        and[3][i] = AND();
        and[3][i].a <== states[i][11];
        and[3][i].b <== and[2][i].out;
        multi_or[0][i] = MultiOR(2);
        multi_or[0][i].in[0] <== and[1][i].out;
        multi_or[0][i].in[1] <== and[3][i].out;
        states[i+1][1] <== multi_or[0][i].out;
        eq[0][i] = IsEqual();
        eq[0][i].in[0] <== in[i];
        eq[0][i].in[1] <== 117;
        and[4][i] = AND();
        and[4][i].a <== states[i][0];
        and[4][i].b <== eq[0][i].out;
        states[i+1][2] <== and[4][i].out;
        eq[1][i] = IsEqual();
        eq[1][i].in[0] <== in[i];
        eq[1][i].in[1] <== 115;
        and[5][i] = AND();
        and[5][i].a <== states[i][2];
        and[5][i].b <== eq[1][i].out;
        states[i+1][3] <== and[5][i].out;
        eq[2][i] = IsEqual();
        eq[2][i].in[0] <== in[i];
        eq[2][i].in[1] <== 101;
        and[6][i] = AND();
        and[6][i].a <== states[i][3];
        and[6][i].b <== eq[2][i].out;
        states[i+1][4] <== and[6][i].out;
        eq[3][i] = IsEqual();
        eq[3][i].in[0] <== in[i];
        eq[3][i].in[1] <== 114;
        and[7][i] = AND();
        and[7][i].a <== states[i][4];
        and[7][i].b <== eq[3][i].out;
        states[i+1][5] <== and[7][i].out;
        eq[4][i] = IsEqual();
        eq[4][i].in[0] <== in[i];
        eq[4][i].in[1] <== 95;
        and[8][i] = AND();
        and[8][i].a <== states[i][5];
        and[8][i].b <== eq[4][i].out;
        states[i+1][6] <== and[8][i].out;
        eq[5][i] = IsEqual();
        eq[5][i].in[0] <== in[i];
        eq[5][i].in[1] <== 105;
        and[9][i] = AND();
        and[9][i].a <== states[i][6];
        and[9][i].b <== eq[5][i].out;
        states[i+1][7] <== and[9][i].out;
        eq[6][i] = IsEqual();
        eq[6][i].in[0] <== in[i];
        eq[6][i].in[1] <== 100;
        and[10][i] = AND();
        and[10][i].a <== states[i][7];
        and[10][i].b <== eq[6][i].out;
        states[i+1][8] <== and[10][i].out;
        eq[7][i] = IsEqual();
        eq[7][i].in[0] <== in[i];
        eq[7][i].in[1] <== 61;
        and[11][i] = AND();
        and[11][i].a <== states[i][8];
        and[11][i].b <== eq[7][i].out;
        states[i+1][9] <== and[11][i].out;
        eq[8][i] = IsEqual();
        eq[8][i].in[0] <== in[i];
        eq[8][i].in[1] <== 51;
        and[12][i] = AND();
        and[12][i].a <== states[i][9];
        and[12][i].b <== eq[8][i].out;
        states[i+1][10] <== and[12][i].out;
        eq[9][i] = IsEqual();
        eq[9][i].in[0] <== in[i];
        eq[9][i].in[1] <== 68;
        and[13][i] = AND();
        and[13][i].a <== states[i][10];
        and[13][i].b <== eq[9][i].out;
        states[i+1][11] <== and[13][i].out;
    }

    signal final_state_sum[num_bytes+1];
    final_state_sum[0] <== states[0][1];
    for (var i = 1; i <= num_bytes; i++) {
        final_state_sum[i] <== final_state_sum[i-1] + states[i][1];
        log("final", final_state_sum[i]);
    }
    out <== final_state_sum[num_bytes];

    signal output reveal[num_bytes];
    for (var i = 0; i < num_bytes; i++) {
        reveal[i] <== in[i] * states[i+1][1];
    }
}
