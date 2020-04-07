%8/4/2016
% Dawei gave me the histogram of counts for each contrast (0-255) for each
% movie. I can use this to generate random noise movies at any resolution.

%load the histogram text file
cd();


%copied this from the web
% Those are your values and the corr. probabilities:

PD =[
  1.0000    0.1000
  2.0000    0.3000
  3.0000    0.4000
  4.0000    0.2000];
% Then make it into a cumulative distribution
D = cumsum(PD(:,2));
% D = [0.1000    0.4000    0.8000    1.0000]'
Now for every r generated by rand, if it is between D(i) and D(i+1), then it corresponds to an outcome PD(1,i+1), with the obvious extension at i==0. Here's a way you could do that, even though I'm sure there are better ones:

R = rand(100,1); % Your trials
p = @(r) find(r<pd,1,'first'); % find the 1st index s.t. r<D(i);
% Now this are your results of the random trials
rR = arrayfun(p,R);
% Check whether the distribution looks right:  
hist(rR,1:4)
% It does, roughly 10% are 1, 30% are 2 and so on