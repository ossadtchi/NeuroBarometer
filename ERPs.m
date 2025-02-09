%   function [Gavg, X, N1] = ERPs(Lb, Ub, EEG, t, chan, texts, M, type, U)  
%   Функция вычисляет вызванные потенциалы (ВП) для всех событий, типы которых перечислены в переменной EEG.event.type
%   
%   Входные переменные:
%   EEG     -   структура EEGLab, в которой хранятся EEG данные.  
%   M       -   Матрица монтажа, определяющая референтную схему.
%   Остальные параметры не используются и могут быть заменены на [] при вызове функции.

%   Выходные переменные:
%   Gavg    -   не вычисляется
%   X       -   тензор размерностью [<число эпох>, <число каналов>, <число временных срезов в эпохе> ]. В данной реализации 
%   число каналов зафиксировано 63, а число временных срезов равно 121.

function [Gavg, X, N1] = ERPs(Lb, Ub, EEG, t, chan, texts, M, type, U)
    %% ERP by event type (text number):
    for i = 1:length({EEG.event.type})
        if isempty(str2num(EEG.event(i).type))==1;
            labels(i) = NaN;
        else
            labels(i) = str2num(EEG.event(i).type);
        end
    end
    
    needed_type = find(ismember(labels, texts));
    lat = [EEG.event(needed_type).latency];
    c = 1;
    X = zeros(length(lat), 63, 121);
    for i = lat
        start = round(i-round(0.1*EEG.srate));
        fin = round(i+round(0.5*EEG.srate));
        tmp = M * EEG.data(1:63,start:fin);
        
        % baseline correction:
        baseline = mean(tmp(:,1:21),2);
        tmp = tmp - baseline;

        X(c,:,:) = tmp;
        c = c + 1;
    end

    Gavg = squeeze(mean(X,1));
    if strcmp(type,'mean')==1
        N1 = squeeze(mean(X(:,chan,Lb:Ub),3));
    end
    if strcmp(type,'median')==1
        N1 = squeeze(median(X(:,chan,Lb:Ub),3));
    end
    if strcmp(type,'median')==0 && strcmp(type,'mean')==0
        error('WRONG TYPE')
    end
    
    
end
