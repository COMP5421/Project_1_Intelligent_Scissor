function varargout = UI(varargin)
% UI MATLAB code for UI.fig
%      UI, by itself, creates a new UI or raises the existing
%      singleton*.
%
%      H = UI returns the handle to a new UI or the handle to
%      the existing singleton*.
%
%      UI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UI.M with the given input arguments.
%
%      UI('Property','Value',...) creates a new UI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UI

% Last Modified by GUIDE v2.5 28-Feb-2018 17:21:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UI_OpeningFcn, ...
                   'gui_OutputFcn',  @UI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before UI is made visible.
function UI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command animatedline arguments to UI (see VARARGIN)

% Choose default command animatedline output for UI
handles.output = hObject;

% Delete the axis ticks
set(handles.ImageView,'xtick',[],'ytick',[]);

% Initialize pictures dimension
handles.width = 0;
handles.length = 0;
handles.dim = 0;

% Initialize relevent pictures
handles.Image = 0; % Original Image
handles.costgraph = 0; % Cost Graph
handles.costfunction = 1; % Cost Function
    

% Initialize mouse position
handles.X = 0;
handles.Y = 0;

% Initialize seed position
handles.seedx = 0;
handles.seedy = 0;

% Initialize scissor mode
handles.mode = 'none'; % Scissor working mode, none/updating

% Initialize animatedline/mask handler
handles.lines = []; % Current unfinished Mask/ Line array
handles.line_num = 0; % Count number of lines the current mask have
handles.Live_Line = 0; % Current updating animated animatedline

handles.Masks = []; % Transform finished contour into mask and save when press enter/ Line array
handles.Mask_Number = 0; % Count number of finished contours
handles.Selected_Mask = 0; % Current selected mask
handles.ShowMask = 'on'; % Only show mask when 'on'

handles.pathtree = 0; % Call C++ function to get pathtree
handles.minpath = 0; % Call C++ function to get minpath

handles.SeedSnapping = 0; % Seed snapping function mode, 0-off / 1-on

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes UI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command animatedline.
function varargout = UI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command animatedline output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function ImageView_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate ImageView
set (gcf, 'WindowButtonMotionFcn', @mouse_Move,'WindowButtonDownFcn',@ImageView_ButtonDownFcn,'KeyPressFcn', @EnterFcn,'DoubleBuffer', 'on');



function mouse_Move(hObject, eventdata, handles)
% Get current mouse position
handles = guidata(hObject);
current_point = get(gca, 'CurrentPoint');
pos = current_point(1,1:2);
y = pos(1); x = pos(2);
x = round(x); y = round(y);
handles.X = x;
handles.Y = y;

% Return if exceed image dimension
if x < 1 || y < 1 || x > handles.width || y > handles.length
    guidata(hObject, handles);
    return
else
    % Update mouse information
    set(handles.X_loc, 'string', ['X: ' num2str(x)]);
    set(handles.Y_loc, 'string', ['Y: ' num2str(y)]);
    
    
    % Update pixel information
    if handles.dim == 3
        r = handles.Image(x,y,1);
        g = handles.Image(x,y,2);
        b = handles.Image(x,y,3);
        set(handles.r_value, 'string', ['R: ' num2str(r)]);
        set(handles.g_value, 'string', ['G: ' num2str(g)]);
        set(handles.b_value, 'string', ['B: ' num2str(b)]);
    else
        set(handles.r_value, 'string', ('R: 0'));
        set(handles.g_value, 'string', ('G: 0'));
        set(handles.b_value, 'string', ('B: 0'));
    end
    
    % Check working status
    switch handles.mode
        case 'none'
            guidata(hObject, handles);
            return
        case 'updating'
            % Delete lines from last call
            if handles.Live_Line == 0
            else
                children = get(gca, 'children');
                delete(children(1));
            end
            
            % Update current cursor position if seed snapping on
            if (handles.SeedSnapping == 1)
                [x, y] = Seed_Snapping( handles.Image,handles.width,handles.length,handles.dim, handles.X, handles.Y );
            end
            % Note: the axis is left handed
            % Find the shortest path from cursor to seed
            m = x;
            n = y;
            point_x = (m); point_y = (n);
            index = handles.width * (n-1) + m;
            while ~isequal([m n],[handles.seedx handles.seedy])
                value = handles.pathtree(m,n) - index;
                switch value  
                    case handles.width-1 % Northeast
                        m = m - 1; n = n + 1;
                        index = index + handles.width - 1;
                        point_x = [point_x m];
                        point_y = [point_y n];                        
                    case handles.width % East
                        n = n + 1;
                        index = index + handles.width;
                        point_x = [point_x m];
                        point_y = [point_y n];                      
                    case handles.width+1 % Southeast
                        m = m + 1; n = n + 1;
                        index = index + handles.width + 1;
                        point_x = [point_x m];
                        point_y = [point_y n];                                               
                    case 1 % South
                        m = m + 1;
                        index = index + 1;
                        point_x = [point_x m];
                        point_y = [point_y n];                       
                    case -1 % North
                        m = m - 1;
                        index = index -1;
                        point_x = [point_x m];
                        point_y = [point_y n];                        
                    case 1-handles.width % Southwest
                        m = m + 1; n = n - 1;
                        index = index - handles.width + 1;
                        point_x = [point_x m];
                        point_y = [point_y n];
                    case -handles.width % West
                        n = n - 1;
                        index = index - handles.width;
                        point_x = [point_x m];
                        point_y = [point_y n];                        
                    case -1-handles.width % Northwest
                        m = m - 1; n = n - 1;
                        index = index - handles.width - 1;
                        point_x = [point_x m];
                        point_y = [point_y n];       
                    otherwise
                        disp('other value');       
                end
            end
            point_x = [point_x handles.seedx]; point_x = fliplr(point_x);
            point_y = [point_y handles.seedy]; point_y = fliplr(point_y);
            handles.Live_Line = animatedline(point_y,point_x,'Parent',gca,'Color', 'g', 'LineStyle', '-', 'LineWidth', 2.0);
    end    
end
guidata(hObject, handles);


% --- Close the contour when Enter is pressed.
% --- Delete elements when backspace is pressed.
function EnterFcn(hObject, eventdata, handles)
handles = guidata(hObject);
switch eventdata.Key
    % When enter is pressed
    case 'return'
        if isequal(handles.mode,'none') || (handles.line_num == 0) || ((handles.X == handles.seedx)&&(handles.Y == handles.seedy)) || (handles.X > handles.width)|| (handles.X < 1)|| (handles.Y > handles.length)|| (handles.Y < 1)
            return
        end
        [checkx, checky] = Seed_Snapping( handles.Image,handles.width,handles.length,handles.dim, handles.X, handles.Y );
        if (handles.SeedSnapping == 1)&&(checkx == handles.seedx)&&(checky == handles.seedy)
            return  
        else
            % Close the contour by call c++ function
            % Get first seed
            [first_y,first_x] = getpoints(handles.lines(1));
            seedx = first_x(1);
            seedy = first_y(1);
            % Connect last cursor position and first seed 
            lastline = animatedline([handles.Y seedy],[handles.X seedx],'Color', 'g', 'LineStyle', '-', 'LineWidth', 2.0);
            handles.lines = [handles.lines handles.Live_Line lastline];
            handles.line_num = handles.line_num + 2;
            
            % Delete previous line segments and merge them into a big line
            all_y = []; all_x = [];
            for i = 1 : handles.line_num
                [y,x] = getpoints(handles.lines(i));
                all_y = [all_y y]; all_x = [all_x x];
                delete(handles.lines(i));
            end
            
            % Add new mask
            mask = animatedline(all_y,all_x,'Parent',gca,'Color', 'g', 'LineStyle', '-', 'LineWidth', 2.0);
            handles.Mask_Number = handles.Mask_Number + 1; % Count number of finished contours
            handles.Masks = [handles.Masks mask]; % Save new mask
            h = handles.Masks;
            set(h, 'ButtonDownFcn', {@LineSelected, h});
           
            % Reset variables
            handles.mode = 'none';
            handles.lines = []; % Current unfinished Mask
            handles.line_num = 0; % Count number of lines the current mask have
            handles.Live_Line = 0; % Current updating animated animatedline
        end
    case {'backspace','delete'}
        if isequal(handles.mode,'none') 
            % Do nothing or delete selected masks
            if handles.Selected_Mask == 0
                guidata(hObject, handles);
                return
            else
                % Find the selected mask and delete it
                index = find(handles.Masks == handles.Selected_Mask);
                delete(handles.Masks(index));
                handles.Masks(index) = [];
                handles.Selected_Mask = 0;
                handles.Mask_Number = handles.Mask_Number - 1;
                
                % Update new array of masks
                mid_mask = handles.Masks;
                handles.Masks = [];
                for i = 1:handles.Mask_Number
                    [new_x,new_y] = getpoints(mid_mask(i));
                    delete(mid_mask(i));
                    new_line = animatedline(new_x,new_y,'Parent',gca,'Color', 'g', 'LineStyle', '-', 'LineWidth', 2.0);
                    handles.Masks = [handles.Masks new_line];
                end             
                set(handles.Masks, 'ButtonDownFcn', {@LineSelected, handles.Masks});   
            end     
        else % Delete current updating lines
            if handles.line_num == 0 % Only the first seed
                if (handles.seedx == handles.X)&&(handles.seedy == handles.Y)
                    return
                end
                handles.seedx = 0;
                handles.seedy = 0;
                handles.mode = 'none';
                delete(handles.Live_Line);
                handles.Live_Line = 0;
            else
                if (handles.seedx == handles.X)&&(handles.seedy == handles.Y)
                    return
                end
                [last_y,last_x] = getpoints(handles.lines(end));
                handles.seedx = last_x(1);
                handles.seedy = last_y(1);
                handles.pathtree = minPath(handles.costgraph, handles.seedx-1, handles.seedy-1);
                handles.minpath = pathTree(handles.costgraph, handles.seedx-1, handles.seedy-1);
                delete(handles.lines(end));
                handles.lines = handles.lines(1:end-1);
                handles.line_num = handles.line_num - 1;
            end
        end  
end
guidata(hObject, handles);


% --- Executes during object deletion, before destroying properties.
function ImageView_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to ImageView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function ImageView_ButtonDownFcn(hObject, eventdata, handles)
handles = guidata(hObject);
seltype = get(gcf,'SelectionType');
switch seltype
    case 'alt' % ctrl + left click
        if isequal(handles.ShowMask,'off') || isequal(handles.Image, 0) || (handles.X > handles.width)|| (handles.X < 1)|| (handles.Y > handles.length)|| (handles.Y < 1)
            return
        end
        if isequal(handles.mode,'none') % Start a new seed, update pathtree and minpath
            if handles.SeedSnapping == 1
                [handles.X, handles.Y] = Seed_Snapping( handles.Image,handles.width,handles.length,handles.dim, handles.X, handles.Y );
            end
            handles.seedx = handles.X;
            handles.seedy = handles.Y;
            handles.pathtree = minPath(handles.costgraph, handles.seedx-1, handles.seedy-1);
            handles.minpath = pathTree(handles.costgraph, handles.seedx-1, handles.seedy-1);
            handles.mode = 'updating';
        else
            if handles.SeedSnapping == 1
                [handles.X, handles.Y] = Seed_Snapping( handles.Image,handles.width,handles.length,handles.dim, handles.X, handles.Y );
            end
            % Quit the unfinished mask and start new seed
            handles.seedx = handles.X;
            handles.seedy = handles.Y;        
            handles.pathtree = minPath(handles.costgraph, handles.seedx-1, handles.seedy-1);
            handles.minpath = pathTree(handles.costgraph, handles.seedx-1, handles.seedy-1);
            
            delete(handles.lines);
            handles.lines = []; % Current unfinished Mask
            handles.line_num = 0; % Count number of lines the current mask have
        end
    case 'normal' % left click
        % Do nothing if not updating
        if isequal(handles.mode,'none')  || (handles.X > handles.width)|| (handles.X < 1)|| (handles.Y > handles.length)|| (handles.Y < 1)
            guidata(hObject, handles);
            return
        else
            handles.line_num = handles.line_num + 1; % Count number of lines the current mask have        
            handles.lines = [handles.lines handles.Live_Line]; % Add animatedline to unfinished mask
            handles.Live_Line = 0; % No Current updating animatedline      
            % Get new seed, update pathtree/minpath
            
            if handles.SeedSnapping == 1
                [handles.seedx, handles.seedy] = Seed_Snapping( handles.Image,handles.width,handles.length,handles.dim, handles.X, handles.Y );
            else
                handles.seedx = handles.X;
                handles.seedy = handles.Y;
            end
            handles.pathtree = minPath(handles.costgraph, handles.seedx-1, handles.seedy-1);
            handles.minpath = pathTree(handles.costgraph, handles.seedx-1, handles.seedy-1);   
        end
end
guidata(hObject, handles);


% Line select function
function LineSelected(hObject, EventData, h)
handles = guidata(hObject);
if isequal(handles.mode,'none') % Only allow selecting line if no updating lines
    handles.Selected_Mask = hObject;
    set(hObject,'Color', 'r', 'LineStyle', '-', 'LineWidth', 4.0); % Set selected line to red and bold
    set(h(h ~= hObject),'Color', 'g', 'LineStyle', '-', 'LineWidth', 2.0); % Set unselected line to g
end
guidata(hObject, handles);


function OpenFile_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to OpenFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get attributes of selected file
[filename,filepath] = uigetfile({'*.*','All Files'}, 'Select Image To Be Displayed');
% Generate warning if no picture selected
if isequal(filename,0)||isequal(filepath,0)
    errordlg('No image selected','Error'); 
    return;  
else
    fullfile = [filepath filename];
    set(handles.text4, 'String', filename);
    ImageFile = imread(fullfile);
    handles.Image = ImageFile;
    [handles.width, handles.length, handles.dim] = size(handles.Image);
    imshow(handles.Image);
    clear axes_scale
    axis off  
    
    % Compute cost graph
    switch handles.costfunction
        case 1
            handles.costgraph = Find_Cost(handles.Image,handles.width,handles.length,handles.dim);
        case 2
            handles.costgraph = Find_Cost2(handles.Image,handles.width,handles.length,handles.dim);
    end
        
    % Initialize live lines
    handles.Live_Line = 0;
    handles.lines = [];
    
    % Initialize mouse position
    handles.X = 0;
    handles.Y = 0;
    
    % Initialize seed position
    handles.seedx = 0;
    handles.seedy = 0;
    
    % Initialize scissor mode
    handles.mode = 'none';
    
    % Initialize animatedline/mask handler
    handles.lines = []; % Current unfinished Mask/ Line array
    handles.line_num = 0; % Count number of lines the current mask have
    handles.Live_Line = 0; % Current updating animated animatedline
    
    handles.Masks = []; % Transform finished contour into mask and save when press enter/ Line array
    handles.Mask_Number = 0; % Count number of finished contours
    
    handles.pathtree = 0; % Call C++ function to get pathtree
    handles.minpath = 0; % Call C++ function to get minpath
    
    handles.Selected_Mask = 0; % Current selected mask
    handles.ShowMask = 'on'; % Only show mask when 'on'
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function WorkMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WorkMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in WorkMode.
function WorkMode_Callback(hObject, eventdata, handles)
% hObject    handle to WorkMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns WorkMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from WorkMode
handles = guidata(hObject);
str = get(hObject, 'String');
val = get(hObject,'Value');

% Generate error if no image selected
if isequal(handles.Image,0)
    errordlg('No image selected','Error'); 
    return;
else
    switch str{val}
        case 'Image Only' 
            % Hide masks
            if handles.Mask_Number ~= 0
                set(handles.Masks,'Visible','off');
            end
            handles.ShowMask = 'off';
        case 'Image&Contour'
            % Show masks
            set(handles.Masks,'Visible','on');
            handles.ShowMask = 'on';
        case 'Gradient Map'
            % Display gradient map
            if handles.dim == 3
                Img = im2uint8(rgb2gray(handles.Image));
                [Gmag,Gdir] = imgradient(Img,'prewitt');
            else
                [Gmag,Gdir] = imgradient(handles.Image,'prewitt');
            end
            figure();
            set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
            imshowpair(Gmag, Gdir, 'montage');
            title('Gradient Magnitude, Gmag (left)                                              Gradient Direction, Gdir (right)');
            clear axes_scale
            axis off
    end
end

% Save the handles structure.
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function DebugMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DebugMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DebugMode.
function DebugMode_Callback(hObject, eventdata, handles)
% hObject    handle to DebugMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DebugMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DebugMode
handles = guidata(hObject);
str = get(hObject, 'String');
val = get(hObject,'Value');

% Generate error information if no picture selectd
if isequal(handles.Image,0)
    errordlg('No image selected','Error'); 
    return;  
else
    switch str{val}
        % Pixel node mode.
        case 'Pixel Node'
            figure();
            set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
            pixelnode = GetPixelNode(handles.Image,handles.width,handles.length,handles.dim);
            imshow(pixelnode);
            clear axes_scale
            axis off       
        % Pixel node mode
        case 'Cost Graph'
            figure();
            set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
            imshow(uint8(handles.costgraph));
            clear axes_scale
            axis off       
        % Path tree mode.
        case 'Path Tree'
            fig = figure();
            set(fig,'units','normalized','outerposition',[0 0 1 1]);
            imshow(uint8(handles.Image));
            hold on
            plot(handles.seedy,handles.seedx, 'y.');
            hold off
            slider1_handle = uicontrol(fig,'Style','slider',...
                'Units','normalized','Position',[.02 .02 .14 .05]);
            uicontrol(fig,'Style','text','Units','normalized','Position',[.02 .07 .14 .04],...
                'String','Choose Ratio','FontSize',12,'FontWeight','bold');
            % Set up callbacks
            vars = struct('slider1_handle',slider1_handle,'minpath',handles.minpath,'seedx',handles.seedx,'seedy',handles.seedy);
            set(slider1_handle,'Callback',{@slider1_callback,vars});
            sliderfcn(vars);
        % Min path mode
        case 'Min Path'
            figure();
            set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
            PathTree = zeros(handles.width*3,handles.length*3,3);
            
            for i = 1:handles.width
                for j = 1:handles.length
                    m = i;
                    n = j;
                    index = handles.width * (n-1) + m;
                    value = handles.pathtree(i,j) - index;
                    switch value
                            case handles.width-1
                                PathTree(3*m-1,3*n-1,:) = [0 255 255];
                                PathTree(3*m-2,3*n,:) = [255 255 0];
                            case handles.width
                                PathTree(3*m-1,3*n-1,:) = [0 255 255];
                                PathTree(3*m-1,3*n,:) = [255 255 0];
                            case handles.width+1
                                PathTree(3*m-1,3*n-1,:) = [0 255 255];
                                PathTree(3*m,3*n,:) = [255 255 0];   
                            case 1
                                PathTree(3*m-1,3*n-1,:) = [0 255 255];
                                PathTree(3*m,3*n-1,:) = [255 255 0];
                            case -1
                                PathTree(3*m-1,3*n-1,:) = [0 255 255];
                                PathTree(3*m-2,3*n-1,:) = [255 255 0];
                            case 1-handles.width
                                PathTree(3*m-1,3*n-1,:) = [0 255 255];
                                PathTree(3*m,3*n-2,:) = [255 255 0];
                            case -handles.width
                                PathTree(3*m-1,3*n-1,:) = [0 255 255];
                                PathTree(3*m-1,3*n-2,:) = [255 255 0];
                            case -1-handles.width
                                PathTree(3*m-1,3*n-1,:) = [0 255 255];
                                PathTree(3*m-2,3*n-2,:) = [255 255 0];
                        case 0
                            PathTree(3*m-1,3*n-1,:) = [0 255 255];
                    end
                end
            end 
            PathTree = uint8(PathTree);
            imshow(PathTree);
    end
end
% Save the handles structure.
guidata(hObject,handles)


% Callback subfunctions to support path tree mode
function slider1_callback(~,~,vars)
    sliderfcn(vars)

    
function sliderfcn(vars)
value = get(vars.slider1_handle,'Value');

if vars.seedx == 0
    return
end
children = get(gca, 'children');
delete(children(1));
[minpath_width , ~] = size(vars.minpath);
minpath = vars.minpath + 1;
num = floor(value * minpath_width);
hold on;  
if num == 0
    plot(vars.seedy,vars.seedx, 'y.');
else
    plot(minpath(1:num,2), minpath(1:num,1), 'y.');
end
hold off;


% Save image with selected mask
function SaveContour_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to SaveContour (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.Selected_Mask == 0
    errordlg('No Mask selected','Error'); 
    return  
end

[filename,~] = uiputfile({'*.jpg';'*.tif';'*.png';'*.gif';'*.*'},'Save as',...
          'Img&Contour.jpg');
if filename
    [x,y] = getpoints(handles.Selected_Mask);
    figure();
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
    image(handles.Image);
    line(x,y,'Color', 'g', 'LineStyle', '-', 'LineWidth', 2.0);
    saveas(gcf,filename,'png');
end


% Save cutted image
function SaveMask_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to SaveMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.Selected_Mask == 0
    errordlg('No Mask selected','Error'); 
    return  
end
[filename,~] = uiputfile({'*.jpg';'*.tif';'*.png';'*.gif';'*.*'},'Save as','Img_Cut.jpg');
if filename
    [x,y] = getpoints(handles.Selected_Mask);
    ROI = poly2mask(x,y,handles.width,handles.length);
    Image_Cutted = bsxfun(@times, handles.Image, cast(ROI, class(handles.Image)));
    figure();
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
    image(Image_Cutted,'alphadata',ROI);
    if handles.dim == 3
        imwrite(Image_Cutted,filename,'png','Transparency',[0 0 0]);
    else
        imwrite(Image_Cutted,filename,'png','Transparency',0);
    end
end


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in seed_snapping.
function seed_snapping_Callback(hObject, eventdata, handles)
% hObject    handle to seed_snapping (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of seed_snapping
handles = guidata(hObject);
value = get(hObject,'Value');
if (value == 1) && isequal(handles.mode,'none')
    handles.SeedSnapping = 1;
else
    handles.SeedSnapping = 0;
    if isequal(handles.mode,'updating')
        errordlg('Finish Current Mask First!','Error'); 
    end
end
guidata(hObject,handles)


% --- Executes on selection change in BlurImage.
function BlurImage_Callback(hObject, eventdata, handles)
% hObject    handle to BlurImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns BlurImage contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BlurImage
% Initialize pictures dimension
if (handles.Image == 0)
    errordlg('No image selected','Error'); 
    return  
end

str = get(hObject, 'String');
val = get(hObject,'Value');

switch str{val}
    case 'No Blur Effect'
        [BluredImage,BluredCostGraph] = Blurimage(handles.Image,handles.width,handles.length,handles.dim,'No Blur Effect',handles.costfunction);
    case 'Blur Sigma: 2'
        [BluredImage,BluredCostGraph] = Blurimage(handles.Image,handles.width,handles.length,handles.dim,'Blur Sigma: 2',handles.costfunction);
    case 'Blur Sigma: 4'
        [BluredImage,BluredCostGraph] = Blurimage(handles.Image,handles.width,handles.length,handles.dim,'Blur Sigma: 4',handles.costfunction);
    case 'Blur Sigma: 8'
        [BluredImage,BluredCostGraph] = Blurimage(handles.Image,handles.width,handles.length,handles.dim,'Blur Sigma: 8',handles.costfunction);
end

imshow(BluredImage);

handles.costgraph = BluredCostGraph;
% Initialize mouse position
handles.X = 0;
handles.Y = 0;

% Initialize seed position
handles.seedx = 0;
handles.seedy = 0;

% Initialize scissor mode
handles.mode = 'none'; % Scissor working mode, none/updating

% Initialize animatedline/mask handler
handles.lines = []; % Current unfinished Mask/ Line array
handles.line_num = 0; % Count number of lines the current mask have
handles.Live_Line = 0; % Current updating animated animatedline

handles.Masks = []; % Transform finished contour into mask and save when press enter/ Line array
handles.Mask_Number = 0; % Count number of finished contours
handles.Selected_Mask = 0; % Current selected mask
handles.ShowMask = 'on'; % Only show mask when 'on'

handles.pathtree = 0; % Call C++ function to get pathtree
handles.minpath = 0; % Call C++ function to get minpath

handles.SeedSnapping = 0; % Seed snapping function mode, 0-off / 1-on
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function BlurImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BlurImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ChooseCostFcn.
function ChooseCostFcn_Callback(hObject, eventdata, handles)
% hObject    handle to ChooseCostFcn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ChooseCostFcn contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ChooseCostFcn
if (handles.Image == 0)
    errordlg('No image selected','Error'); 
    return  
end

str = get(hObject, 'String');
val = get(hObject,'Value');

switch str{val}
    case 'CostFcn'
        handles.costfunction = 1;
        handles.costgraph = Find_Cost(handles.Image,handles.width,handles.length,handles.dim);
    case 'CostFcn2'
        handles.costfunction = 2;
        handles.costgraph = Find_Cost2(handles.Image,handles.width,handles.length,handles.dim);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ChooseCostFcn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChooseCostFcn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end