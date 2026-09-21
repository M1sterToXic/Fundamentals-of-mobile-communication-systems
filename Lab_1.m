clc
%% 1,2,3
t = 0:0.001:1;
f = 4;
y = cos(2*pi*f*t) + sin(10*pi*f*t) + sin(6*t);
figure;
title("Лаба 1");
plot(t, y, "g");
grid("on")
hold on;
disp("2 пункт: делим максимально высокую кампоненту на 2пи, и умножаем на f. Получаем 5*4 = 20Гц");
disp("3 пункт: минимальная необходимая частота дискретизации полученного сигнала = 40Гц");
%% 4
y = @(t) cos(2*pi*f*t) + sin(10*pi*f*t) + sin(6*t);
f = 80;
t = 0:1/f:1;
masx = t;
masy = y(t);
plot(masx, masy, "r*-");
grid on;
legend("Оригинал", "Восстановленный");
%% 5
f = 80;
t = 0:1/f:1;
masy = y(t);
N = length(masy);
Y = fft(masy); %Преобразование Фурье
mag = abs(Y) / N;
mag = mag(1:floor(N/2)+1);
mag(2:end-1) = 2 * mag(2:end-1);

f_axis = f * (0:floor(N/2)) / N;

figure;
plot(f_axis, mag, "b");
title("Амплитудный спектр сигнала");
grid on;
xlabel("Частота Гц");
ylabel("Амплитуда");
info = whos('masy');
disp("Пункт 5: " + info.bytes + "Б");
%% 6 
t = 0:0.001:1;
y = cos(8*pi*t) + sin(40*pi*t) + sin(6*t);
f = 80;
t_discret = 0:1/f:1;
y_discret = cos(8*pi*t_discret) + sin(40*pi*t_discret) + sin(6*t_discret);

figure;
plot(t, y, "g");
hold on;
plot(t_discret, y_discret, "r*-");
grid on;
title("Сравнение сигналов");
xlabel("Время, с");
ylabel("Амплитуда");
legend("Оригинал", "Восстановленный");
%% 7 
f = 320;
t = 0:1/f:1;
masy = cos(8*pi*t) + sin(40*pi*t) + sin(6*t);
N = length(masy);
Y = fft(masy); %Преобразование Фурье
mag = abs(Y) / N;
mag = mag(1:floor(N/2)+1);
mag(2:end-1) = 2 * mag(2:end-1);
f_axis = f * (0:floor(N/2)) / N;

figure;
plot(f_axis,mag, "b");
title("Амплитудный спектр (f = 320 Гц)");
grid on;
xlabel("Частота Гц");
ylabel("Амплитуда");
info = whos("masy");
disp("Пункт 7: Размер массива: " + string(info.bytes) + " байт");

t_ideal = 0:0.001:1;
y_ideal = cos(8*pi*t_ideal) + sin(40*pi*t_ideal) + sin(6*t_ideal);

figure;
plot(t_ideal, y_ideal, "g");
hold on;
plot(t, masy, "r*-");
grid on;
title("Сравнение сигналов (f = 320 Гц)");
xlabel("Время, с");
ylabel("Амплитуда");
legend("Оригинал", "Восстановленный");
%% 8 & 9
[y_voice, Fs] = audioread('voice.wav');
disp("Пункт 9: Оригинальная частота дискретизации Fs: " + string(Fs) + " Гц");
N_voice = length(y_voice);
disp("Пункт 9: Количество отсчетов в записи: " + string(N_voice));
%% 10
t_audio = 38.440; 
Fs_calculated = N_voice / t_audio;
disp("Пункт 10: Вычисленная частота дискретизации: " + string(Fs_calculated) + " Гц");
disp("Пункт 10: Частота Fs из файла: " + string(Fs) + " Гц");
%% 11
y1 = downsample(y_voice, 10);
zvuk = audioplayer(y1, Fs/10); 

% play(zvuk); 
% stop(zvuk) в терминал
figure;
plot(y1);
title("Временной сигнал после прореживания");
xlabel("Отсчеты");
ylabel("Амплитуда");
%% 12
N_orig = length(y_voice);
Y_orig = fft(y_voice);
mag_orig = abs(Y_orig) / N_orig;
mag_orig = mag_orig(1:floor(N_orig/2)+1);
mag_orig(2:end-1) = 2 * mag_orig(2:end-1);
f_axis_orig = Fs * (0:floor(N_orig/2)) / N_orig;

N_down = length(y1);
Y_down = fft(y1);
mag_down = abs(Y_down) / N_down;
mag_down = mag_down(1:floor(N_down/2)+1);
mag_down(2:end-1) = 2 * mag_down(2:end-1);
Fs_new = Fs / 10;
f_axis_down = Fs_new * (0:floor(N_down/2)) / N_down;

figure;
subplot(2, 1, 1);
plot(f_axis_orig, mag_orig, "g");
title("Спектр оригинального сигнала");
xlabel("Частота, Гц");
ylabel("Амплитуда");
grid on;

subplot(2, 1, 2);
plot(f_axis_down, mag_down, "r");
title("Спектр прореженного сигнала");
xlabel("Частота, Гц");
ylabel("Амплитуда");
grid on;
%% 13
f_samp = 320; 
t = 0:1/f_samp:1;
y = cos(8*pi*t) + sin(40*pi*t) + sin(6*t);
ymin = min(y);
ymax = max(y);
bits_array = [3, 4, 5, 6];

for i = 1:length(bits_array)
    b = bits_array(i);
    max_level = 2^b - 1; 

    y_norm = (y - ymin) / (ymax - ymin);
    y_quant_int = round(y_norm * max_level);
    y_quant_int(y_quant_int > max_level) = max_level; 
    y_quant_int(y_quant_int < 0) = 0;
    y_quant = y_quant_int / max_level * (ymax - ymin) + ymin;
    mean_error = mean(abs(y - y_quant));
    fprintf('Пункт 13: Средняя ошибка квантования для %d бит: %f\n', b, mean_error);

    if b == 3
        N = length(y);

        Y_orig = fft(y);
        mag_orig = abs(Y_orig)/N; 
        mag_orig = mag_orig(1:floor(N/2)+1); 
        mag_orig(2:end-1) = 2*mag_orig(2:end-1);

        Y_quant = fft(y_quant);
        mag_quant = abs(Y_quant)/N; 
        mag_quant = mag_quant(1:floor(N/2)+1); 
        mag_quant(2:end-1) = 2*mag_quant(2:end-1);

        f_axis = f_samp * (0:floor(N/2)) / N;

        figure;
        subplot(2,1,1);
        plot(f_axis, mag_orig, 'b'); 
        title('Спектр исходной синусоиды'); 
        ylabel('Амплитуда'); grid on;

        subplot(2,1,2);
        plot(f_axis, mag_quant, 'r'); 
        title('Спектр квантованного сигнала (3 бита)'); 
        xlabel('Частота, Гц'); ylabel('Амплитуда'); grid on;
    end
end