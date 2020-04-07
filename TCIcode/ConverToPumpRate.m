function [ r ] = ConverToPumpRate( rate, weight, drugConc )
%UNTITLED Summary of this function goes here
%   rate is assumed to be in mg/kg/min.
%  weight is asumed to be in grams


weight=weight/1000;             % convert to kg

r=rate(:,1)*weight;             % convert to mg/min
r=1000*(r/drugConc);                % convert to ul/min



end

