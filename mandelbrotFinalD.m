function mandelbrotFinalD(center,spacing,iters,pix,lineNum,expon,colorm)
% * mandelbrot(center,spacing,iters,pix,expon,colorm)
%
% ******************* P A R A M E T E R S ********************
% _ center = the c-value for center of the image in the argand plane
%       :(ie center=1.1+.3i for point (1.1,0.3) )
% _ spacing = difference for the interval of both axes
% _ iters = the number of iteration per pixel
%       + more iterations allow for zooming in deeper
%       + input of 0 will make the drawing continue until figure is closed
% _ pix = pixel size of the graphic
% _ lineNum = number of lines displayed when moving the mouse. Lines show
% the iteration process for the point the mouse is hovering over
%       + input of 0 will not show lines
% _ expon = the fractal exponent. Input of 2 produces the Mandelbrot Fractal
% _ colorm = the colors that the fractal will be displayed with.
%       + colormaps: jet, hsv, hot, cool, spring, summer, autumn,
% winter, gray, bone, copper, pink, lines, random
%
% ******************* U S A G E ********************
% _ Click on image once to activate zooming. Click and drag on the image to
% select area to zoom into
% _ Use mouse wheel to switch back and forth between previously viewed
% fractals
%
% * mandelbrot(center,spacing,iters,pix,expon,colorm)

%*******************************************************************
%
%   Mandelbrot Generator by Longphi Nguyen and Kevin Nelson
%
%   Final Version, Dec 20, 2010
%
% *******************************************************************

% Doubling the iters will result in requiring over double the processing
% time. Doubling the pixels will result in increasing the processing time
% by 300 percent. At least 400 is recommended.
%
% Changing the fractal exponent will create different multibrot fractals.
% Some can be quite fascinating!
%

%*************************************************************************
%                    ===== B E G I N =====
%*************************************************************************
fprintf('\n\n')
filename=mfilename;

% Checks how many values are entered in at the command line; set defaults
% for other parameters.
if nargin < 1, center=-.75+0i; end % c value for center point
if nargin < 2, spacing = 2.5; end % range for the fractal
if nargin < 3, iters = 30; end % iterations for the fractal
if nargin < 4, pix = 500; end %size of figure in pixels
if nargin < 5, lineNum = 5; end % color mapping
if nargin < 6, expon = 2; end % exponent playground.
if nargin < 7, colorm = hot; end % color mapping

xcoor=real(center);
ycoor=imag(center);
% initialize variables (calculations for these are done later)
xmin=0;
xmax=0;
ymin=0;
ymax=0;

close all

%*************************************************************************
%                    ===== I N I T I A L I Z E =====
%*************************************************************************

% + calculations to determine position of figure and size of figure
set(0,'Units','pixels') % ensures that size measurements are in pixels
screensize=get(0,'ScreenSize'); % returns some number, some number, width, height
pos=[(screensize(1,3)-pix)/2 (screensize(1,4)-pix)/2]; % used to determine positioning of image
if(screensize(1,3)>=screensize(1,4))
    if(pix>screensize(1,4)) % when pixel>height
        pix=screensize(1,4);
        pos(1,2)=0;
    end
elseif(pix>screensize(1,3)) % when pixel>width
    pix=screensize(1,3);
    pos(1,1)=0;
end

% + initialize figure and handle functions
fig=figure('Name','Mandelbrot Set','NumberTitle','off');
gridAxes=axes('XLim',[-2,2],'YLim',[-2,2]); % Used as a grid to detect mouse position
set(fig,'Position',[pos(1,1),pos(1,2),pix,pix]);
set(fig,'WindowButtonDownFcn',{@wbd});
set(fig,'WindowScrollWheelFcn',{@wsw});
set(fig,'WindowButtonMotionFcn',{@wbm});

% + initialize some matrices
zeroes = zeros(pix,pix); % simply a matrix with zeros
if lineNum>0
    mouseXMatrix=zeros(1,lineNum); % used to detect mouse position
    mouseYMatrix=zeros(1,lineNum); % " " " " "
    hline=line(mouseXMatrix,mouseYMatrix); % arbitrary initial line
end

% + initialize some variables
finished=0; % indicates whether the fractal was finished drawing (this is here for variable initialization purposes)
change=0; % initialize variable. Indicates if a new image is to be drawn, with different parameters. (ie zooming)
mouseX=0;
mouseY=0;

% + initialize matrix for mandelbrot command display
functSettings=zeros(6,1); % 6=displayed parameters and # fractals drawn
fracNum=1; % keeps track of which fractal the user is looking at

%*************************************************************************
%                    ===== S T A R T =====
%*************************************************************************

drawFractal();

waitfor(fig); % checks for when the image is closed, then proceeding lines are run

% + Displays command printouts with parameters for all viewed fractals
fprintf('-------------------------------------------------------------\n')
[~,n]=size(functSettings);
for disp=1:n
    fracNum=disp;
    displayFracInfo();
end

%*************************************************************************
%                    ===== F U N C T I O N S =====
%*************************************************************************

% + Ensures the dimensions are equal (square). ie, when zooming in, the area
% selected may not always be square, so this makes it square.
    function squarize()
        s=spacing/2;
        xmin=xcoor-abs(s);
        xmax=xcoor+abs(s);
        ymax=ycoor-abs(s);
        ymin=ycoor+abs(s);
        
        coordiff = ((abs(xmin-xmax))-(abs(ymax-ymin)))/2;
        if (coordiff > 0) % x coordinates are more spaced
            ymax=ymax-coordiff;
            ymin=ymin+coordiff;
        else % y coordinates are more spaced
            xmin=xmin+coordiff;
            xmax=xmax-coordiff;
        end
        spacing=abs(ymax-ymin);% doesnt matter if xmin and xmax were used        
    end

% + Saves parameter information
    function saveFracInfo()
        %save these values into a matrix to be displayed later
        center=xcoor+ycoor*1i;
        functSettings(1,fracNum)=center;
        functSettings(2,fracNum)=spacing;
        functSettings(3,fracNum)=iters;
        functSettings(4,fracNum)=pix;
        functSettings(5,fracNum)=lineNum;
        functSettings(6,fracNum)=expon;
    end

% + Displays information about the parameters used to create each image
    function displayFracInfo()
        fprintf('  (%s) >> %s(%s,%s,%s,%s,%s,%s)\n',num2str(fracNum),filename,num2str(functSettings(1,fracNum)),num2str(functSettings(2,fracNum)),num2str(functSettings(3,fracNum)),num2str(functSettings(4,fracNum)),num2str(functSettings(5,fracNum)),num2str(functSettings(6,fracNum))) %displays the command, but not the mapping used
    end

% + Draws the mandelbrot fractal, and called when zooming to create a new image
    function drawFractal()
        tic
        
        finished=0; % indicates whether the fractal was finished drawing
        change=0; % indicates that the user is disrupting the process
        
        squarize();
        saveFracInfo();
        displayFracInfo();
        
        x = linspace(xmin,xmax,pix);    % fill x vector values for mandel
        y = linspace(ymin,ymax,pix);    % fill y vector values for mandel
        [a,b] = meshgrid(x,y); %grid
        
        % This creates a grid to represent the real and imaginary axes for an
        % argand plane
        C = complex(a,b); % c is complex: c = a + bi
        
        %mandelbrot setup
        z = zeroes; %keeps track of calculations
        itersTilDiverge = zeroes; %keeps track of when things diverge
        
        %grid setup to track mouse position on the grid
        axis off
        gridAxes=axes('XLim',[xmin,xmax],'YLim',[ymax,ymin]);
        
        if (iters>0)
            step=1;% only have an endpoint to the program if the user set an iters value
        else
            step=0;%indicates the program will run forever
        end
        
        while (step <= iters && change==0 && ishandle(fig)==1)
            z = z.^expon + C; % calculates z_{n+1} = z_{n}^2 + c,
            % developing the main fractal values
            itersTilDiverge = itersTilDiverge + (abs(z)<=2); % checks for divergence when the magnitude
            % of z values is < 2, the value is not divergent yet and the
            % (abs(z)<=2) will return 1 (else, 0).
            % Therefore, values that take longer to diverge, if ever, are
            % associated with higher values in itersTilDiverge.
            imagesc(x,y,itersTilDiverge); %creates the image using itersTilDiverge as the basis
            
            colormap(colorm); %colors the image based on how relatively high the itersTilDiverge
            % values are
            if (lineNum>0)
                hline=line(mouseXMatrix,mouseYMatrix,'LineWidth',1);
            end
            
            xlabel(mouseX);
            ylabel(mouseY);
            
            if (iters>0)
                step = step+1;% only have an endpoint to the program if the user set an iters value
            end
            pause(.01); % Note: this will mean there will be at least .01*iters more delay than normal delay
        end
        
        % [X] This was added to compare the speed of our current
        % method. Our current method turns out to be about 5x faster
        % without the pause line
        %         for m=1:iters
        %             for j=1:pix %rows
        %                 for k=1:pix %columns
        %                     if (map(j,k) < m-1)
        %                         z(j,k)=z(j,k)^2+C(j,k);
        %                         if (abs(z(j,k))<2)
        %                             map(j,k) = map(j,k)+1;
        %                         end
        %                     end
        %                     k=k+1;
        %                 end
        %                 j=j+1;
        %             end
        %             m=m+1;
        %         end
        %         imagesc(x,y,map);
        %         colormap(colorm);
        
        %checks if there is at least 1 divergent point, else colorizes
        %the image(it would not show color if there are no divergent
        %points)
        if(min(itersTilDiverge)==iters)
            itersTilDiverge(1,1)=0;
            imagesc(x,y,itersTilDiverge); %creates the image using itersTilDiverge as the basis
            colormap(colorm); %colors the image based on how relatively high the itersTilDiverge
            % values are
        end
        
        % + adds handles again
        try
            set(fig,'WindowScrollWheelFcn',{@wsw});
            set(fig,'WindowButtonMotionFcn',{@wbm});
        catch
            % ('figure was closed')
        end
        finished=1; % drawing was finished
        toc
    end

%*************************************************************************
%                    ===== F E A T U R E S =====
%*************************************************************************

% + Detects when the user clicks the mouse and allows the user to select an
% area to zoom in to
    function wbd(~,~)
        try
            rect=getrect(); % xmin, ymax, width, height
            if(rect(1,3)>spacing*.05 && rect(1,4)>spacing*.05)%the rectangle must be large enough (to prevent accidental clicks on small areas)
                xcoor=rect(1,1)+rect(1,3)/2;
                ycoor=rect(1,2)+rect(1,4)/2;
                if(rect(1,3)>rect(1,4))
                    spacing=rect(1,3);
                else
                    spacing=rect(1,4);
                end
                
                change=1;
                while(finished==1 && change==1) %waits until the current image is finished drawing
                    fracNum=fracNum+1;
                    [~,n]=size(functSettings);
                    if(fracNum > n)
                        functSettings(:,fracNum)=0;
                    end
                    drawFractal();
                end
            end
        catch
            %('Figure closed w/o choosing rectangle')
        end
        
    end

% + Allows the user to use the scroll wheel to go back and forth between
% previous entries (created when zooming in to different areas)
    function wsw(~,evd)
        % this will delete any successive fractals: ie, when
        %viewing fractal#2, then trying to zoom at an area, that new
        %fractal will replace fractal#3
        [~,n]=size(functSettings);
        if(n>1) %there must be more than 1 fractal
            if(evd.VerticalScrollCount>0) %scroll down
                if(fracNum<=1)
                    fracNum=n;%go to last fractal
                else
                    fracNum=fracNum-1;%go to previous fractal
                end
            else
                %scroll up
                if(fracNum>=n) %go back to first fractal
                    fracNum=1;
                else
                    fracNum=fracNum+1;%go to next fractal
                end
            end
            
            xcoor=functSettings(1,fracNum);%xcoor
            ycoor=functSettings(2,fracNum);%ycoor
            spacing=functSettings(3,fracNum);%spacing
            
            change=1;
            while(finished==1 && change==1) %waits until the current image is finished drawing
                drawFractal();
            end
        end
    end

% + Tracks mouse movement and calculates some iterations based on mouse
% location
    function wbm(~,~)
            try
                delete(hline)
            catch
                %no line to delete
            end
            mouseInfo=get(gridAxes,'CurrentPoint');
            mouseX=mouseInfo(1,1);
            mouseY=mouseInfo(1,2);
            
            if(lineNum>0)
                mouseC = complex(mouseX,mouseY);
                z2=0;
                
                step2=1;
                while(step2<=lineNum)
                    z2 = z2.^expon + mouseC;
                    mouseXMatrix(1,step2)=real(z2);
                    mouseYMatrix(1,step2)=imag(z2);
                    step2=step2+1;
                end
                hline=line(mouseXMatrix,mouseYMatrix,'LineWidth',1);
            end
            xlabel(mouseX);
            ylabel(mouseY);
    end

%unused functions, but good to know about:
%
%     function wbu(fig,evd)
%         %disp('up')
%
%         %props=getappdata(fig,'TestGuiCallbacks');
%         %set(fig,props);
%     end

end

