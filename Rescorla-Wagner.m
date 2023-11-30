%Rescorla-Wagner model used in Fig. 3 of De Jong et al.
% outputs:
% - vecChoice: choice of animal (0 = left, 1 = right)
% - vecActive: site of high-probability hole (0 = left, 1 = right)
% - vecWinLose: rewarded or not (0 = time-out, 1 = rewarded)
% - vecLeft: value of left nosepoke hole
% - vecRight: value or right nosepoke hole

clear all
clc

%% Main script 

%Just fill in alpha+, alpha-, beta, and the number of trials, and click
%play!
[vecChoice, vecActive, vecWinLose, vecLeft, vecRight] = revlearn_simulate(0.2, 0.2, 2, 200);


%% plot figure

figure
subplot(3,1,1)
plot(vecActive)
set(gca, 'YTick', [0 1])
set(gca, 'YTickLabel', {'left', 'right'})
xlim([0 length(vecChoice)])
title('Site of high-probability hole')

subplot(3,1,2)
scatter(intersect(find(vecChoice == 1), find(vecWinLose == 0)), ones(1,length(intersect(find(vecChoice == 1), find(vecWinLose == 0)))), 'r')
hold on
scatter(intersect(find(vecChoice == 1), find(vecWinLose == 1)), ones(1,length(intersect(find(vecChoice == 1), find(vecWinLose == 1)))), 'g')
scatter(intersect(find(vecChoice == 0), find(vecWinLose == 0)), zeros(1,length(intersect(find(vecChoice == 0), find(vecWinLose == 0)))), 'r')
scatter(intersect(find(vecChoice == 0), find(vecWinLose == 1)), zeros(1,length(intersect(find(vecChoice == 0), find(vecWinLose == 1)))), 'g')
set(gca, 'YTick', [0 1])
set(gca, 'YTickLabel', {'left', 'right'})
xlim([0 length(vecChoice)])
title('Choice of animal')
legend({'lose', 'win'})

subplot(3,1,3)
plot(vecLeft, 'k')
hold on
plot(vecRight, 'r')
xlim([0 length(vecChoice)])
ylim([0 1])
title('Modeled nosepoke values')
legend({'left np', 'right np'})
xlabel('Trial #')
ylabel('Q value')

%% function containing simulator

function [vecChoice, vecActive, vecWinLose, vecLeft, vecRight] = revlearn_simulate(alpha_plus, alpha_minus, beta, num_trials)

for iter = 1:num_trials
    
    %% pre allocate vectors for modeling
    vecChoice = nan(num_trials,1);
    vecActive = nan(num_trials,1);
    vecWinLose = nan(num_trials,1);
    vecLeft = nan(num_trials,1);
    vecRight = nan(num_trials,1);

    
    %% run simulation
        
    valLeft = 0.5;
    valRight = 0.5;
    active = 1;
    activesum = 0;
    
    lowOdds = [1 0 0 0 0]; %odds of winning low probability hole
    highOdds = [0 1 1 1 1]; %odds of winning high probability hole
    
    for i = 1 : num_trials %loop through trials
        
        pRight = exp(beta*valRight)/( exp(beta * valLeft) + exp(beta * valRight) ); %softmax
        
        %make choice
        if pRight > rand %right choice
            choice = 1;
        else
            choice = 0;
        end
        
        %task is probabilistic, so determine if reward is obtained in this
        %trial
        if choice == active %if high probabily hole is chosen
            activesum = activesum + 1;
            winlose = randsample(highOdds,1);
        else % if low probability hole is chosen
            winlose = randsample(lowOdds,1);
            activesum = 0;
        end
        
        %update value
        if choice == 1 &&  winlose == 1 %right chosen, right won
            valRight = valRight + alpha_plus*(1 - valRight); %Rescorla-Wagner
        elseif choice == 1 &&  winlose == 0 %right chosen, right lost
            valRight = valRight + alpha_minus*(0 - valRight); %Rescorla-Wagner
        elseif choice == 0 &&  winlose == 1 %left chosen, left won
            valLeft = valLeft + alpha_plus*(1-valLeft); %Rescorla-Wagner
        elseif choice == 0 &&  winlose == 0 %left chosen, left lost
            valLeft = valLeft + alpha_minus*(0-valLeft); %Rescorla-Wagner
        end
        
        
        %do reversal after 8 choices for high-prob
        if activesum == 8
            
            if active == 1
                active = 0;
            elseif active == 0
                active = 1;
            end
            
            activesum = 0;
            
        end
        
        %save trial-to-trial data
        vecChoice(i) = choice;
        vecActive(i) = active;
        vecWinLose(i) = winlose;
        vecLeft(i) = valLeft;
        vecRight(i) = valRight;
        
        
    end

    
end
end