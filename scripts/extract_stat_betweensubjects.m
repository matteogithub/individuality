n_sbjs=11;
n_sess=2;
n_tasks=4;
n_eps=10;
c_wtask=0;
c_btask=0;

v_wt=zeros((n_sbjs*(n_sbjs-1)/2)*n_tasks*n_sess,1);
v_bt=zeros(((n_tasks*n_sess*n_tasks*n_sess-n_tasks*n_sess)/2)*(n_sbjs*(n_sbjs-1)/2),1);

for i=1:n_sbjs
    sb_i_max=n_tasks*i*n_eps*n_sess;
    sb_i_min=sb_i_max-n_tasks*n_eps*n_sess+1;
    for ii=1:n_sbjs
        sb_ii_max=n_tasks*ii*n_eps*n_sess;
        sb_ii_min=sb_ii_max-n_tasks*n_eps*n_sess+1;
        if(i<ii)
            curr_m=dist_mat(sb_i_min:sb_i_max,sb_ii_min:sb_ii_max);
            for j=1:n_tasks*n_sess
                ind_j_max=j*n_eps;
                ind_j_min=ind_j_max-n_eps+1;                
                for k=1:n_tasks*n_sess
                    ind_k_max=k*n_eps;
                    ind_k_min=ind_k_max-n_eps+1;
                    if(j==k)
                        c_wtask=c_wtask+1;
                        v_wt(c_wtask)=sum(sum(curr_m(ind_j_min:ind_j_max,ind_k_min:ind_k_max)))/(10*10);
                    elseif(j<k)
                        c_btask=c_btask+1;
                        v_bt(c_btask)=sum(sum(curr_m(ind_j_min:ind_j_max,ind_k_min:ind_k_max)))/(10*10);
                    end                    
                end                
            end
        end        
    end    
end