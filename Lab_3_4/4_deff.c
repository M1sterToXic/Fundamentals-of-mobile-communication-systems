#include <stdio.h>
#include <stdlib.h>

int chek(const int *seq, int N)
{
    printf("=== Проверка последовательности (длина N = %d) ===\n\n", N);

    if (N < 3)
    {
        printf("Последовательность слишком короткая.\n");
        return 0;
    }

    int m = 0;
    while (((1ULL << m) - 1) < (unsigned long long)N)
    {
        m++;
    }
    int is_m_len = (((1ULL << m) - 1) == (unsigned long long)N);

    printf("0) Длина вида 2^m - 1:\n");
    if (is_m_len)
        printf("   N = %d = 2^%d - 1 -> выполнено\n\n", N, m);
    else
        printf("   N = %d не равно 2^m - 1 -> не выполнено\n\n", N);

    int ones = 0, zeros = 0, binary_ok = 1;
    for (int i = 0; i < N; i++)
    {
        if (seq[i] == 1)
            ones++;
        else if (seq[i] == 0)
            zeros++;
        else
            binary_ok = 0;
    }
    int balance_ok = binary_ok && (ones - zeros == 1);

    printf("1) Баланс (balance):\n");
    printf("   единиц = %d, нулей = %d, разница (1 - 0) = %d\n", ones, zeros, ones - zeros);
    printf("   Результат: %s\n\n", balance_ok ? "выполнено" : "не выполнено");

    int *run_len = (int *)calloc(N + 1, sizeof(int));
    int *run_ones = (int *)calloc(N + 1, sizeof(int));
    int *run_zeros = (int *)calloc(N + 1, sizeof(int));

    int start = 0;
    int all_equal = 1;
    for (int i = 0; i < N; i++)
    {
        int prev = seq[(i - 1 + N) % N];
        if (seq[i] != prev)
        {
            start = i;
            all_equal = 0;
            break;
        }
    }

    int max_run = 0;
    if (all_equal)
    {
        run_len[N] = 1;
        if (seq[0] == 1)
            run_ones[N] = 1;
        else
            run_zeros[N] = 1;
        max_run = N;
    }
    else
    {
        int current_len = 1;
        for (int step = 1; step < N; step++)
        {
            int idx = (start + step) % N;
            int prev_idx = (start + step - 1) % N;
            if (seq[idx] == seq[prev_idx])
            {
                current_len++;
            }
            else
            {
                run_len[current_len]++;
                if (seq[prev_idx] == 1)
                    run_ones[current_len]++;
                else
                    run_zeros[current_len]++;
                if (current_len > max_run)
                    max_run = current_len;
                current_len = 1;
            }
        }
        int last_idx = (start + N - 1) % N;
        run_len[current_len]++;
        if (seq[last_idx] == 1)
            run_ones[current_len]++;
        else
            run_zeros[current_len]++;
        if (current_len > max_run)
            max_run = current_len;
    }

    int total = 0;
    for (int k = 1; k <= N; k++)
        total += run_len[k];

    int runs_ok = is_m_len && ((unsigned long long)total == (1ULL << (m - 1))) && (max_run == m);
    int limit_k = (is_m_len && m > max_run) ? m : max_run;

    printf("2) Цикличность (runs, всего серий по кругу = %d):\n", total);
    printf("   Длина | Кол-во (1 / 0) | Доля     | Ожидается\n");
    printf("   ------+----------------+----------+----------\n");

    for (int k = 1; k <= limit_k; k++)
    {
        double share = (total > 0) ? (double)run_len[k] / total : 0.0;
        if (is_m_len)
        {
            int exp_ones = 0, exp_zeros = 0;
            if (k <= m - 2)
            {
                exp_ones = 1 << (m - 2 - k);
                exp_zeros = 1 << (m - 2 - k);
            }
            else if (k == m - 1)
            {
                exp_zeros = 1;
            }
            else if (k == m)
            {
                exp_ones = 1;
            }

            int exp_total = exp_ones + exp_zeros;
            double expected = (double)exp_total / (double)(1ULL << (m - 1));

            if (run_ones[k] != exp_ones || run_zeros[k] != exp_zeros)
                runs_ok = 0;

            printf("   %5d | %4d (%2d / %2d) | %6.1f%%  | %5.1f%% (%d шт.)\n",
                   k, run_len[k], run_ones[k], run_zeros[k],
                   share * 100.0, expected * 100.0, exp_total);
        }
        else
        {
            printf("   %5d | %4d (%2d / %2d) | %6.1f%%  |     -\n",
                   k, run_len[k], run_ones[k], run_zeros[k], share * 100.0);
        }
    }

    printf("   Результат: %s\n\n", runs_ok ? "выполнено" : "не выполнено");

    free(run_len);
    free(run_ones);
    free(run_zeros);

    printf("3) Автокорреляция:\n");
    printf("   Сдвиг | Совпадений | Несовпадений |    R(τ)\n");
    printf("   ------+------------+--------------+----------\n");

    int auto_ok = 1;
    for (int shift = 0; shift < N; shift++)
    {
        int same = 0;
        int diff = 0;
        for (int i = 0; i < N; i++)
        {
            int shifted_bit = seq[(i + shift) % N];
            if (seq[i] == shifted_bit)
                same++;
            else
                diff++;
        }
        double R = (double)(same - diff) / N;
        printf("   %5d | %10d | %12d | %8.4f", shift, same, diff, R);

        if (shift == 0)
        {
            printf("  (пик)\n");
            if (same - diff != N)
                auto_ok = 0;
        }
        else
        {
            printf("\n");
            if (same - diff != -1)
                auto_ok = 0;
        }
    }
    printf("   Результат: %s\n\n", auto_ok ? "выполнено" : "не выполнено");

    int is_m_seq = is_m_len && balance_ok && runs_ok && auto_ok;
    printf("ИТОГ: Последовательность %s М-последовательностью.\n",
           is_m_seq ? "ЯВЛЯЕТСЯ" : "НЕ ЯВЛЯЕТСЯ");

    return is_m_seq;
}

int main(void)
{
    int seq[] = {1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 0, 0};
    int N = sizeof(seq) / sizeof(seq[0]);
    chek(seq, N);
    return 0;
}