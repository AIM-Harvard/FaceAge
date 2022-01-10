
path = 'C:\Users\ozala\Documents\PythonWork\FaceNet\results\Survey\Survival-Curves\';

load(strcat(path, 'data_surv_curves.mat'));

x = [0 0.25 0.5 1 1.5 2];

nImages = length(data);

figure;


for idx = 2:nImages
    y = 100*[data{idx,2} data{idx,3} data{idx,4} data{idx,5} data{idx,6} data{idx,7}]
    disp(y)
    plot(x,y,'LineWidth',2.5)
    ax = gca;
    ax.FontSize = 14;
    %title(['y = x^n,  n = ' num2str( n(idx)) ])
    title('Predicted Survival Curve')
    axis([0 2 0 100])
    xlabel('Years','FontSize',14) %,...
       %'FontWeight','bold')
    ylabel('Survival Probability','FontSize',14) %,...
       %'FontWeight','bold')
    drawnow
    frame = getframe(1);
    im{idx} = frame2im(frame);
end
close;


%figure;
%for idx = 1:nImages
%    subplot(3,3,idx)
%    imshow(im{idx});
%end
path = [path, 'Images\']
for idx = 2:nImages
    [A,map] = rgb2ind(im{idx},256);
    filename = strcat(path,data{idx,1})
    filename = strcat(filename, '.jpg')
    %if idx == 1
    %    imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1);
    %else
    %    imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1);
    %end

    imwrite(A,map,filename,'jpeg');
end