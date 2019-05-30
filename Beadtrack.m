 function poslist=Beadtrack(filehead,digit,first,last,feature,threshold,lnoise,interactive,MarkerSize,moviedt)
% out=cntrd(im,mx,sz,interactive)
%
%PURPOSE
%           For each image in a directory
%              Read image file
%                Filter the image
%                Find brightest pixels
%                Find pixel centroids
%                Concatenate positions to pos_lst
%
%INPUT:
%filehead: A string common to the image file names
%          i.e. we assume that the filename is of the form ’framexxxx.tif’
%
%start: First frame to read
% end: Final frame to read
%
%feature: Expected size of the particle (diameter)
%
%NOTES:
%
%OUTPUTS:
%
%CREATED: Eric M. Furst, University of Delaware, July 23, 2013
% Modifications:

tic
if mod(feature,2) == 0
     warning('feature size must be an odd value');
     poslist=[];
     return;
end

if nargin==7, interactive = 0; end
poslist=[];
for frame=first:last
    
    if interactive == 0
        if mod(frame,100)==0
           disp(['Frame number: ' num2str(frame)]);
        end
    end
    
    % read in file
    image = imread([filehead, num2str(frame,digit),'.tif']);
    image = flipud(image);
    
    image1 = 65535 - image;
    
    % Bandpass filter
    imagebp = bpass(image1,lnoise,feature);
    
    % Find locations of the brightest pixels Need to change the 'th'
    % (threshold) argument to something that is specified or determined.
    % Current value is 8000. A rough guide is 0.6*max(imagebp(:))
    pk = pkfnd(imagebp,threshold,feature);
    % Refine location estimates using centroid
    cnt = cntrd_RZ(imagebp, pk, feature+2);
    
    if isempty(cnt) == 1
        disp(['Tracking breaks at frame:', num2str(frame)]);
        return
    end
    
    cnt(:,6) = frame;
    poslist = [poslist; cnt];
    
    if interactive == 0    
    elseif interactive == 1
        if mod(frame,moviedt) == 0
            colormap('gray'), imagesc(image);
            title(['Frame number: ' num2str(frame)],'fontweight','bold','Fontsize',18,'color','b');
            set(gca,'YDir','normal');
            axis equal;
            hold on;
            plot_pix(cnt(:,1),cnt(:,2),MarkerSize,'r','o')
            hold off;
            pause(0.1)
        end
    elseif interactive == 2
        if mod(frame,moviedt) == 0
                minp = min(cnt(:,5));
                ind =find(cnt(:,5)==minp);
                ind2 = find(abs(pk(:,1)-cnt(ind,1))<5 & abs(pk(:,2)-cnt(ind,2))<5);
                image2 = image(pk(ind2,2)-35:pk(ind2,2)+35,pk(ind2,1)-35:pk(ind2,1)+35);
                colormap('gray');imagesc(image2);
                title(['Frame number: ' num2str(frame)],'fontweight','bold','Fontsize',18,'color','b');
                set(gca,'YDir','normal');
                axis equal;
                hold on;
                plot_pix((36+cnt(ind,1)-pk(ind2,1)),(36+cnt(ind,2)-pk(ind2,2)),MarkerSize,'r','o')
                hold off;
                pause(0.1)
        end
    end          
end
toc
load chirp
sound(y,Fs)

% It’s better to separate the particle tracking from the trajectory
% analysis. Once the particles are located in each frame, we can re-run the
%trajectory anslysis using different parameters.
%
% After generating the unsorted position lists, run track.m to generate the
% particle trajectories. The routine takes the following input:
% For the input data structure (positionlist):
%        (x)       (y)    (t)
% pos = 3.60000 5.00000 0.00000
%       15.1000 22.6000 0.00000
%       4.10000 5.50000 1.00000
%       15.9000 20.7000 2.00000
%       6.20000 4.30000 2.00000
%
%     Use the command:
% trajectories = track([pos_lst(:,1:2),pos_lst(:,5)],10);
