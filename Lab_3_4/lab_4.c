#include <stdio.h>

int main() {
    // %% 1
    int x[5] = {0, 1, 1, 1, 0};
    int y[5] = {1, 0, 1, 0, 1};
    int gold[31];

    for (int i = 0; i < 31; i++) {
        gold[i] = x[4] ^ y[4];

        int fb_x = x[3] ^ x[4];
        int fb_y = y[1] ^ y[4];

        for (int j = 4; j > 0; j--) {
            x[j] = x[j - 1];
            y[j] = y[j - 1];
        }

        x[0] = fb_x;
        y[0] = fb_y;
    }

    printf("Последовательность Голда (31 бит):\n");
    for (int i = 0; i < 31; i++) {
        printf("%d ", gold[i]);
    }
    printf("\n");

    // %% 2
    int shifted[31];
    for (int i = 0; i < 31; i++) {
        shifted[i] = gold[i];
    }

    printf("\nСдвиг | Последовательность                                            | АКФ\n");
    for (int s = 0; s <= 31; s++) {
        int match = 0;
        int mismatch = 0;
        for (int i = 0; i < 31; i++) {
            if (gold[i] == shifted[i]) {
                match++;
            } else {
                mismatch++;
            }
        }
        double acf = (double)(match - mismatch) / 31.0;

        printf("%5d | ", s);
        for (int i = 0; i < 31; i++) {
            printf("%d ", shifted[i]);
        }
        printf("| %6.3f\n", acf);

        int last = shifted[30];
        for (int i = 30; i > 0; i--) {
            shifted[i] = shifted[i - 1];
        }
        shifted[0] = last;
    }

    // %% 3
    int x2[5] = {0, 1, 1, 1, 1};
    int y2[5] = {1, 0, 0, 0, 0};
    int gold2[31];

    for (int i = 0; i < 31; i++) {
        gold2[i] = x2[4] ^ y2[4];

        int fb_x = x2[3] ^ x2[4];
        int fb_y = y2[1] ^ y2[4];

        for (int j = 4; j > 0; j--) {
            x2[j] = x2[j - 1];
            y2[j] = y2[j - 1];
        }

        x2[0] = fb_x;
        y2[0] = fb_y;
    }

    printf("\nВторая последовательность Голда (31 бит):\n");
    for (int i = 0; i < 31; i++) {
        printf("%d ", gold2[i]);
    }
    printf("\n");

    // %% 4
    int match2 = 0;
    int mismatch2 = 0;
    for (int i = 0; i < 31; i++) {
        if (gold[i] == gold2[i]) {
            match2++;
        } else {
            mismatch2++;
        }
    }
    double ccf = (double)(match2 - mismatch2) / 31.0;

    printf("\nВзаимная корреляция: %.3f\n", ccf);

    return 0;
}
