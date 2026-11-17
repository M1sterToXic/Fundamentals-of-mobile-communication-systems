clc;
%% 1
x = [0 1 1 1 0];
y = [1 0 1 0 1];
gold = zeros(1, 31);

for i = 1:31
    gold(i) = xor(x(5), y(5));

    fb_x = xor(x(4), x(5));
    fb_y = xor(y(2), y(5));

    x = [fb_x x(1:4)];
    y = [fb_y y(1:4)];
end

fprintf('1) Последовательность Голда (31 бит):\n');
fprintf('%d ', gold);
fprintf('\n');

%% 2
shifted = gold;
acf = zeros(1, 32);

fprintf('\n 2) Сдвиг | Последовательность                                            | АКФ\n');
for s = 0:31
    match = sum(gold == shifted);
    mismatch = sum(gold ~= shifted);
    acf(s + 1) = (match - mismatch) / 31;

    fprintf('%5d | ', s);
    fprintf('%d ', shifted);
    fprintf('| %6.3f\n', acf(s + 1));

    shifted = [shifted(31) shifted(1:30)];
end

%% 3
x2 = [0 1 1 1 1];
y2 = [1 0 0 0 0];
gold2 = zeros(1, 31);

for i = 1:31
    gold2(i) = xor(x2(5), y2(5));

    fb_x = xor(x2(4), x2(5));
    fb_y = xor(y2(2), y2(5));

    x2 = [fb_x x2(1:4)];
    y2 = [fb_y y2(1:4)];
end

fprintf('\n 3) Вторая последовательность Голда (31 бит):\n');
fprintf('%d ', gold2);
fprintf('\n');

%% 4
match2 = sum(gold == gold2);
mismatch2 = sum(gold ~= gold2);
ccf = (match2 - mismatch2) / 31;

fprintf('\n 4) Взаимная корреляция: %.3f\n', ccf);

%% 5
[acf_auto, lags_auto] = autocorr(gold, 'NumLags', 30);
[xc_val, lags_xc] = xcorr(2*gold - 1, 2*gold2 - 1, 'coeff');
[acf_xcorr, lags_ac] = xcorr(2*gold - 1, 'coeff');

fprintf('\n 5) Сравнение АКФ (lag = 0..5):\n');
fprintf('Сдвиг | Цикл. АКФ | autocorr() | xcorr()\n');
for s = 0:5
    fprintf('%5d | %9.3f | %10.3f | %7.3f\n', s, acf(s + 1), acf_auto(s + 1), acf_xcorr(31 + s));
end
fprintf('\nВзаимная корреляция (lag = 0): вручную = %.3f, xcorr() = %.3f\n', ccf, xc_val(31));

%% 6
shifted2 = gold2;
acf2 = zeros(1, 32);

for s = 0:31
    match = sum(gold2 == shifted2);
    mismatch = sum(gold2 ~= shifted2);
    acf2(s + 1) = (match - mismatch) / 31;
    shifted2 = [shifted2(31) shifted2(1:30)];
end

figure;
plot(0:31, acf, '-o', 'LineWidth', 1.5);
hold on;
plot(0:31, acf2, '-x', 'LineWidth', 1.5);
grid on;
title('Зависимость автокорреляционной функции от величины задержки (lag)');
xlabel('Задержка (lag)');
ylabel('Автокорреляция');
legend('АКФ 1-й последовательности', 'АКФ 2-й последовательности');
hold off;