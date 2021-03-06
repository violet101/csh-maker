%change a list of oxygens that are connected to only one silicon to Oh and
%add an H

function [coords,elems,num_exist] = change_si_oh(coords,elems,trans_mat,num_exist)

%find o connected to one Si
o_id = find(ismember(elems,{'Ob','Od'}) & num_exist);
si_id = find(ismember(elems,{'Si','Sib'}) & num_exist);
si_extend = box_extend(coords(si_id,:),trans_mat);
rcut = 2; o_one_si = [];
for io = o_id'
    
    dist = pnt_dist(si_extend,coords(io,:));
    tmp = find(dist<rcut);
    tmp = mod(tmp,length(si_id)); %revert back to the actual numbering
    tmp(tmp==0) = length(si_id);
    
    if sum(dist<2)==1
        o_one_si = [o_one_si; io];
    end
    
end

if ~isempty (o_one_si)
    elem_layer = elems(logical(num_exist)); %only the elements in the current model
    num_si = sum(ismember(elem_layer,{'Si','Sib'}));
    num_ca = sum(ismember(elem_layer,{'Ca','Cw'}));
    ca_si_ratio = num_ca / num_si;
    
    mid = mean(coords);
    o_one_top = o_one_si(coords(o_one_si,3)>mid(3));
    o_one_bot = o_one_si(coords(o_one_si,3)<mid(3));
    
    n_o_one = length(o_one_si);
    n_sioh_add = round(num_si*(ca_si_ratio-.46));
    if n_sioh_add>n_o_one
        o_rand_top=o_one_top;
        o_rand_bot=o_one_bot;
    else
        n_sioh_top=round(n_sioh_add/2);
        n_sioh_bot=n_sioh_add-n_sioh_top;
        o_rand_top=randsample(o_one_top,n_sioh_top); %some dangling Ob
        o_rand_bot=randsample(o_one_bot,n_sioh_bot);
    end
    
    o_change = [o_rand_top;o_rand_bot];
    
    elems(o_change)={'Os'};
    elems = [elems;repmat({'H'},length(o_change),1)];
    coords = [coords;coords(o_change,:)+[0 1 0]];
    num_exist(end+1:end + length(o_change))=1;
end