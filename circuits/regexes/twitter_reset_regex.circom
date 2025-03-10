pragma circom 2.1.5;

include "./regex_helpers.circom";

template TwitterResetRegex (msg_bytes) {
    signal input msg[msg_bytes];
    signal output out;

    var num_bytes = msg_bytes;
    signal in[num_bytes];
    for (var i = 0; i < msg_bytes; i++) {
        in[i] <== msg[i];
    }

    component eq[23][num_bytes];
    component lt[12][num_bytes];
    component and[29][num_bytes];
    component multi_or[3][num_bytes];
    signal states[num_bytes+1][23];

    for (var i = 0; i < num_bytes; i++) {
      states[i][0] <== 1;
    }
    for (var i = 1; i < 23; i++) {
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
      eq[0][i] = IsEqual();
      eq[0][i].in[0] <== in[i];
      eq[0][i].in[1] <== 95;
      and[3][i] = AND();
      and[3][i].a <== states[i][1];
      multi_or[0][i] = MultiOR(4);
      multi_or[0][i].in[0] <== and[0][i].out;
      multi_or[0][i].in[1] <== and[1][i].out;
      multi_or[0][i].in[2] <== and[2][i].out;
      multi_or[0][i].in[3] <== eq[0][i].out;
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
      eq[1][i] = IsEqual();
      eq[1][i].in[0] <== in[i];
      eq[1][i].in[1] <== 95;
      and[7][i] = AND();
      and[7][i].a <== states[i][22];
      multi_or[1][i] = MultiOR(4);
      multi_or[1][i].in[0] <== and[4][i].out;
      multi_or[1][i].in[1] <== and[5][i].out;
      multi_or[1][i].in[2] <== and[6][i].out;
      multi_or[1][i].in[3] <== eq[1][i].out;
      and[7][i].b <== multi_or[1][i].out;
      multi_or[2][i] = MultiOR(2);
      multi_or[2][i].in[0] <== and[3][i].out;
      multi_or[2][i].in[1] <== and[7][i].out;
      states[i+1][1] <== multi_or[2][i].out;
      eq[2][i] = IsEqual();
      eq[2][i].in[0] <== in[i];
      eq[2][i].in[1] <== 101;
      and[8][i] = AND();
      and[8][i].a <== states[i][0];
      and[8][i].b <== eq[2][i].out;
      states[i+1][2] <== and[8][i].out;
      eq[3][i] = IsEqual();
      eq[3][i].in[0] <== in[i];
      eq[3][i].in[1] <== 109;
      and[9][i] = AND();
      and[9][i].a <== states[i][2];
      and[9][i].b <== eq[3][i].out;
      states[i+1][3] <== and[9][i].out;
      eq[4][i] = IsEqual();
      eq[4][i].in[0] <== in[i];
      eq[4][i].in[1] <== 97;
      and[10][i] = AND();
      and[10][i].a <== states[i][3];
      and[10][i].b <== eq[4][i].out;
      states[i+1][4] <== and[10][i].out;
      eq[5][i] = IsEqual();
      eq[5][i].in[0] <== in[i];
      eq[5][i].in[1] <== 105;
      and[11][i] = AND();
      and[11][i].a <== states[i][4];
      and[11][i].b <== eq[5][i].out;
      states[i+1][5] <== and[11][i].out;
      eq[6][i] = IsEqual();
      eq[6][i].in[0] <== in[i];
      eq[6][i].in[1] <== 108;
      and[12][i] = AND();
      and[12][i].a <== states[i][5];
      and[12][i].b <== eq[6][i].out;
      states[i+1][6] <== and[12][i].out;
      eq[7][i] = IsEqual();
      eq[7][i].in[0] <== in[i];
      eq[7][i].in[1] <== 32;
      and[13][i] = AND();
      and[13][i].a <== states[i][6];
      and[13][i].b <== eq[7][i].out;
      states[i+1][7] <== and[13][i].out;
      eq[8][i] = IsEqual();
      eq[8][i].in[0] <== in[i];
      eq[8][i].in[1] <== 119;
      and[14][i] = AND();
      and[14][i].a <== states[i][7];
      and[14][i].b <== eq[8][i].out;
      states[i+1][8] <== and[14][i].out;
      eq[9][i] = IsEqual();
      eq[9][i].in[0] <== in[i];
      eq[9][i].in[1] <== 97;
      and[15][i] = AND();
      and[15][i].a <== states[i][8];
      and[15][i].b <== eq[9][i].out;
      states[i+1][9] <== and[15][i].out;
      eq[10][i] = IsEqual();
      eq[10][i].in[0] <== in[i];
      eq[10][i].in[1] <== 115;
      and[16][i] = AND();
      and[16][i].a <== states[i][9];
      and[16][i].b <== eq[10][i].out;
      states[i+1][10] <== and[16][i].out;
      eq[11][i] = IsEqual();
      eq[11][i].in[0] <== in[i];
      eq[11][i].in[1] <== 32;
      and[17][i] = AND();
      and[17][i].a <== states[i][10];
      and[17][i].b <== eq[11][i].out;
      states[i+1][11] <== and[17][i].out;
      eq[12][i] = IsEqual();
      eq[12][i].in[0] <== in[i];
      eq[12][i].in[1] <== 109;
      and[18][i] = AND();
      and[18][i].a <== states[i][11];
      and[18][i].b <== eq[12][i].out;
      states[i+1][12] <== and[18][i].out;
      eq[13][i] = IsEqual();
      eq[13][i].in[0] <== in[i];
      eq[13][i].in[1] <== 101;
      and[19][i] = AND();
      and[19][i].a <== states[i][12];
      and[19][i].b <== eq[13][i].out;
      states[i+1][13] <== and[19][i].out;
      eq[14][i] = IsEqual();
      eq[14][i].in[0] <== in[i];
      eq[14][i].in[1] <== 97;
      and[20][i] = AND();
      and[20][i].a <== states[i][13];
      and[20][i].b <== eq[14][i].out;
      states[i+1][14] <== and[20][i].out;
      eq[15][i] = IsEqual();
      eq[15][i].in[0] <== in[i];
      eq[15][i].in[1] <== 110;
      and[21][i] = AND();
      and[21][i].a <== states[i][14];
      and[21][i].b <== eq[15][i].out;
      states[i+1][15] <== and[21][i].out;
      eq[16][i] = IsEqual();
      eq[16][i].in[0] <== in[i];
      eq[16][i].in[1] <== 116;
      and[22][i] = AND();
      and[22][i].a <== states[i][15];
      and[22][i].b <== eq[16][i].out;
      states[i+1][16] <== and[22][i].out;
      eq[17][i] = IsEqual();
      eq[17][i].in[0] <== in[i];
      eq[17][i].in[1] <== 32;
      and[23][i] = AND();
      and[23][i].a <== states[i][16];
      and[23][i].b <== eq[17][i].out;
      states[i+1][17] <== and[23][i].out;
      eq[18][i] = IsEqual();
      eq[18][i].in[0] <== in[i];
      eq[18][i].in[1] <== 102;
      and[24][i] = AND();
      and[24][i].a <== states[i][17];
      and[24][i].b <== eq[18][i].out;
      states[i+1][18] <== and[24][i].out;
      eq[19][i] = IsEqual();
      eq[19][i].in[0] <== in[i];
      eq[19][i].in[1] <== 111;
      and[25][i] = AND();
      and[25][i].a <== states[i][18];
      and[25][i].b <== eq[19][i].out;
      states[i+1][19] <== and[25][i].out;
      eq[20][i] = IsEqual();
      eq[20][i].in[0] <== in[i];
      eq[20][i].in[1] <== 114;
      and[26][i] = AND();
      and[26][i].a <== states[i][19];
      and[26][i].b <== eq[20][i].out;
      states[i+1][20] <== and[26][i].out;
      eq[21][i] = IsEqual();
      eq[21][i].in[0] <== in[i];
      eq[21][i].in[1] <== 32;
      and[27][i] = AND();
      and[27][i].a <== states[i][20];
      and[27][i].b <== eq[21][i].out;
      states[i+1][21] <== and[27][i].out;
      eq[22][i] = IsEqual();
      eq[22][i].in[0] <== in[i];
      eq[22][i].in[1] <== 64;
      and[28][i] = AND();
      and[28][i].a <== states[i][21];
      and[28][i].b <== eq[22][i].out;
      states[i+1][22] <== and[28][i].out;
    }

    // The number of times the regex matches so far; in this case, the start of a twitter username
    // Should be 0 for invalid emails and 1 for valid emails, we should never see a 2 or more
    signal final_state_sum[num_bytes+1];
    final_state_sum[0] <== states[0][1];
    for (var i = 1; i <= num_bytes; i++) {
      final_state_sum[i] <== final_state_sum[i-1] + states[i][1];
    }
    out <== final_state_sum[num_bytes];

    // Vector that masks the email with mostly 0s, but reveals the twitter username
    signal output reveal[num_bytes];
    for (var i = 0; i < num_bytes; i++) {
        reveal[i] <== in[i] * states[i+1][1];
    }
}
