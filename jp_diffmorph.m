function warped = jp_diffmorph(img, maxDistortion, nSteps)
%JP_DIFFMORPH Create diffeomorphicially warped images.
%
%
% Based on original code from Bobby Stojanoski and Rhodri Cusack. If used,
% please cite:
%
% Stojanoski B, Cusack R (2014) Time to wave good-bye to phase scrambling:
% Creating controlled scrambled images using diffeomorphic transformations.
% J Vis 14:1?16.
%
% * img - input image
% * maxDistortion - warping distortion level
% * nSteps - number of warping iterations
% * warped - warped image
% 
% Notes from original code:
% 
% ===========================================================================
% Create diffewarped images.    
% Number of morphed steps (images) is set by 'nsteps' with the amout of morphing held constant between images.
% Amount of morphing is set by 'maxdistortion'
% Each morphed images is saved as a jpeg. 
% In figure (11), each morphed images is also positioned along the outline of a circle 
% Please reference: Stojanoski, B., & Cusack, R (213). Time to wave goodbye to phase scrambling ñ creating unrecognizable control stimuli using a diffeomorphic transform.  Abstract Vision Science Society
% Note: Mturk perceptual ratings of images are based on maxdistortion = 80; and nsteps = 20


if nargin < 3 || isempty(nSteps)
    nSteps = 20;
end

if nargin < 2 || isempty(maxDistortion)
    maxDistortion = 80;
end



% Image size
imgSize = size(img);
outImgSize = 2 * max(imgSize); % size of output images (bigger or equal to 2 x input image)



%% Warping

% figure(10);

[YI XI]=meshgrid(1:outImgSize,1:outImgSize);

phaseoffset=floor(rand(1)*40);

Im=uint8(ones(outImgSize,outImgSize,3)*256); %128 for grey bckground and 256 for white
P=img;
P=P(:,:,1:3);
Psz=size(P);

% Upsample by factor of 2 in two dimensions
P2=zeros([2*Psz(1:2),Psz(3)]);
P2(1:2:end,1:2:end,:)=P;
P2(2:2:end,1:2:end,:)=P;
P2(2:2:end,2:2:end,:)=P;
P2(1:2:end,2:2:end,:)=P;
P=P2;
Psz=size(P);

% Pad image if necessary
x1=round((outImgSize-Psz(1))/2);
y1=round((outImgSize-Psz(2))/2);

% Add fourth plane if necessary
if (Psz(3)==4)
    Im(:,:,4)=0;
end
Im((x1+1):(x1+Psz(1)),(y1+1):(y1+Psz(2)),:)=P;

[cxA cyA]=getdiffeo(outImgSize,maxDistortion,nSteps);
[cxB cyB]=getdiffeo(outImgSize,maxDistortion,nSteps);
[cxF cyF]=getdiffeo(outImgSize,maxDistortion,nSteps);

interpIm=Im;

for quadrant=1:4
    switch (quadrant)
        case 1
            cx=cxA;
            cy=cyA;
            ind=1;
            indstep=1;
        case 2
            cx=cxF-cxA;
            cy=cyF-cyA;
        case 3
            ind=4*nSteps;
            indstep=-1;
            interpIm=Im;
            cx=cxB;
            cy=cyB;
        case 4
            cx=cxF-cxB;
            cy=cyF-cyB;
    end
    cy=YI+cy;
    cx=XI+cx;
    mask=(cx<1) | (cx>outImgSize) | (cy<1) | (cy>outImgSize) ;
    cx(mask)=1;
    cy(mask)=1;
    %     figure(10);
    %     subplot (4,2,quadrant*2-1)
    %     imagesc(cx)
    %     subplot (4,2,quadrant*2)
    %     imagesc(cy)
    w=0.1;
    for j=1:nSteps %This is the number of steps - Total number of warps is nsteps * quadrant
        centrex=0.5+(0.5-w/2)*cos((phaseoffset+ind)*2*pi/(4*nSteps));
        centrey=0.5+(0.5-w/2)*sin((phaseoffset+ind)*2*pi/(4*nSteps));
        %         figure(11);
        %         if (mod(ind,2)==0)
        %             axes('position',[centrex-w/2 centrey-w/2 w w]);
        %             imagesc(interpIm(:,:,1:3));
        %             axis off
        %         end
        interpIm(:,:,1)=interp2(double(interpIm(:,:,1)),cy,cx);
        interpIm(:,:,2)=interp2(double(interpIm(:,:,2)),cy,cx);
        interpIm(:,:,3)=interp2(double(interpIm(:,:,3)),cy,cx);
        ind=ind+indstep;
    end
end

% Output image
warped = interpIm;


end  % function warped = diffWarp(img, maxDistortion, nSteps, IMG_TYPE)


%% Sub-functions

function [XIn YIn]=getdiffeo(imsz,maxdistortion,nsteps)

ncomp=6;

[YI XI]=meshgrid(1:imsz,1:imsz);

% make diffeomorphic warp field by adding random DCTs
ph=rand(ncomp,ncomp,4)*2*pi;
a=rand(ncomp,ncomp)*2*pi;
Xn=zeros(imsz,imsz);
Yn=zeros(imsz,imsz);

for xc=1:ncomp
    for yc=1:ncomp
        Xn=Xn+a(xc,yc)*cos(xc*XI/imsz*2*pi+ph(xc,yc,1))*cos(yc*YI/imsz*2*pi+ph(xc,yc,2));
        Yn=Yn+a(xc,yc)*cos(xc*XI/imsz*2*pi+ph(xc,yc,3))*cos(yc*YI/imsz*2*pi+ph(xc,yc,4));
    end
end

% Normalise to RMS of warps in each direction
Xn=Xn/sqrt(mean(Xn(:).*Xn(:)));
Yn=Yn/sqrt(mean(Yn(:).*Yn(:)));

YIn=maxdistortion*Yn/nsteps;
XIn=maxdistortion*Xn/nsteps;

end % function getdiffeo
