function [ g, q ] = CheckPumpTarget( p )
% given the serial object will read the entire buffer and look for the
% termination T* which indicates that infusion is complete. Output
% variables g contains the conent of the buffer, q is 1 if infusion is
% complete, zero if it is not complete and empty if the buffer is empty
    by=get(p, 'BytesAvailable');
    
    if by>=2
        g=fread(p, by);
        r=g(end-1:end);   
        q=isequal(r, [84,42]');
    else
        g=[];
        q=[];
    end




end

