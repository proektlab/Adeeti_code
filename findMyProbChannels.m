function [probeChan, mmInGrid] = findMyProbChannels(probeName)

if contains(probeName, 'T4')
    probeChan = [[29 0 31 0 16 0 1 0 3];...
                      [0 23 0 32 0 2 0 9 0];...
                      [28 0 24 0 18 0 10 0 6];...
                      [0 25 0 17 0 15 0 7 0];...
                      [27 0 22 0 13 0 12 0 5];...
                      [0 30 0 20 0 14 0 4 0];...
                      [26 0 21 0 19 0 11 0 8]];
    mmInGrid = [.75, 3];
elseif contains(probeName, 'T2')
    probeChan = [[19	17	15	13];...
                [30	47	49	4];...
                [42	50	1	56];...
                [43	48	31	53];...
                [44	18	16	54];...
                [22	29	3	12];...
                [27	32	2	5];...
                [39	45	51	57];...
                [40	46	52	58];...
                [41	20	14	55];...
                [28	23	9	6];...
                [37	36	62	59];...
                [24	38	60	10];...
                [33	25	7	63];...
                [35	34	64	61];...
                [26	21	11	8]];
    mmInGrid = [1.4, 2.1];
    
    elseif contains(probeName, 'E64-500-20-60')
    probeChan = [[5 17 0 0 48 60];...
                [6 18 28 37 47 59];...
                [7 19 29 36 46 58];...
                [8 20 30 35 45 57];...
                [9 21 31 34 44 56];...
                [10 22 32 33 43 55];...
                [11 16 27 38 49 54];...
                [4 15 26 39 50 61];...
                [3 14 25 40 51 62];...
                [2 13 24 41 52 63];...
                [1 12 23 42 53 64]];
    mmInGrid = [2.75, 5];
end

        