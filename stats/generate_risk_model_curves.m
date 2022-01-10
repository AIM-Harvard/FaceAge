%
% MATLAB script for automated generation of FaceAge risk model survival curve jpeg images for survey
%
% The code and data of this repository are intended to promote reproducible research of the paper
% "$PAPER_TITLE"
% Details about the project can be found at the following webpage:
% https://aim.hms.harvard.edu/$FACEAGE_HANDLE

% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
% NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
% NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
%
% AIM 2022

path = '.\';

% load raw survival data
load(strcat(path, 'data_surv_curves.mat'));

% observation time interval of 2 years
x = [0 0.25 0.5 1 1.5 2];

% number of cases
nImages = length(data);


% plot survival curves and create image for each
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

% set output path to image folder
path = [path, 'Images\']

% convert RGB image to indexed image that is written as jpeg
for idx = 2:nImages
    [A,map] = rgb2ind(im{idx},256);
    filename = strcat(path,data{idx,1})
    filename = strcat(filename, '.jpg')
    imwrite(A,map,filename,'jpeg');
end
