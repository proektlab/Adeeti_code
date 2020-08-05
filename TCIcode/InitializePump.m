function [ p ] = InitializePump( port, directory )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

%default baud rate
b=115200;
% close all instrumentsﬂ
if ~isempty(instrfindall);
    fclose(instrfindall);
end
% define and configure serial port object
p=serial(port);
set(p, 'BaudRate',b , 'StopBits', 1, 'Terminator','CR/LF', 'Parity', 'none', 'FlowControl', 'none');
% open object

fopen(p);
% flush out all of the commands 
flushinput(p);
flushoutput(p);
% set baud rate and read it
fprintf(p, ['BAUD ',num2str(b), '\n']);
fprintf(p, 'BAUD');
disp(fscanf(p));

%turn off echo
fprintf(p, 'ECHO OFF\n');
fprintf(p, 'ECHO\n');
disp(fscanf(p));


% clear all of the infusion times
disp('Clear all volumes');
fprintf(p, 'CVOLUME\n');
disp('Clear all infusion times');
fprintf(p, 'CITIME\n');

p.RecordDetail='verbose';
p.RecordName = [directory, '/', 'PumpOutput.txt'];
record(p,'on');
end

