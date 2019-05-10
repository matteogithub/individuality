dist_mat=zeros(size(profiles,1),size(profiles,1));
score_mat=zeros(size(profiles,1),size(profiles,1));


for r=1:size(profiles,1)
    for c=1:size(profiles,1)
        if(r~=c)
            dist_mat(r,c)=norm(profiles(r,:)-profiles(c,:));
            score_mat(r,c)=1./(1+dist_mat(r,c));
        end
    end
end