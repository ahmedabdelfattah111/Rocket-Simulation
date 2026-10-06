function window5(trajectory_data, cairo_coords, target_coords, specs)
    % WINDOW5 - Flat Earth 3D Visualization with 6DOF Rocket Simulation
    % OPTIMIZED: reduced mesh, minimal redraws, pre-computed data

    if isempty(trajectory_data)
        errordlg('No trajectory data available. Run simulation first.', 'Error');
        return;
    end

    n = size(trajectory_data, 1);
    t_arr      = cell2mat(trajectory_data(:,1));
    v_arr      = cell2mat(trajectory_data(:,2));
    alt_arr    = cell2mat(trajectory_data(:,3));
    dist_arr   = cell2mat(trajectory_data(:,4));
    lat_arr    = cell2mat(trajectory_data(:,5));
    lon_arr    = cell2mat(trajectory_data(:,6));
    gamma_arr  = cell2mat(trajectory_data(:,7));
    thrust_arr = cell2mat(trajectory_data(:,8));
    drag_arr   = cell2mat(trajectory_data(:,9));
    mass_arr   = cell2mat(trajectory_data(:,10));

    RE_km = 6371;
    lat0  = cairo_coords.lat;
    lon0  = cairo_coords.lon;
    d2km_lat = (pi/180) * RE_km;
    d2km_lon = (pi/180) * RE_km * cosd(lat0);

    % --- Flat-earth XYZ ---
    X_traj = (lon_arr - lon0) * d2km_lon;
    Y_traj = (lat_arr - lat0) * d2km_lat;
    Z_traj = alt_arr;

    X_target = (target_coords.lon - lon0) * d2km_lon;
    Y_target = (target_coords.lat - lat0) * d2km_lat;

    % --- 6DOF attitude (pre-computed) ---
    pitch_arr = gamma_arr;
    yaw_arr   = zeros(n,1);
    roll_arr  = zeros(n,1);
    for i = 1:n-1
        dx = X_traj(i+1)-X_traj(i);
        dy = Y_traj(i+1)-Y_traj(i);
        yaw_arr(i) = rad2deg(atan2(dx,dy));
    end
    yaw_arr(n) = yaw_arr(n-1);

    arrow_scale = max(alt_arr)*0.18;
    ax_vec = zeros(n,3);
    for i = 1:n
        p = deg2rad(pitch_arr(i)); y = deg2rad(yaw_arr(i));
        ax_vec(i,:) = [cos(p)*sin(y), cos(p)*cos(y), sin(p)] * arrow_scale;
    end

    % --- Scene bounds ---
    margin = max([abs(X_target),abs(Y_target)])*0.2 + 30;
    xr = [min([0,X_traj',X_target])-margin, max([0,X_traj',X_target])+margin];
    yr = [min([0,Y_traj',Y_target])-margin, max([0,Y_traj',Y_target])+margin];
    z_max = max(alt_arr)*1.25;

    % ===================== FIGURE =====================
    fig5 = figure('Name','6DOF Flat-Earth Trajectory', ...
        'Position',[50 0 1350 800], ...
        'Color',[0.04 0.04 0.10], ...
        'NumberTitle','off', ...
        'Renderer','opengl');

    % ===================== 3D AXES =====================
    ax3d = axes(fig5,'Position',[0.01 0.22 0.57 0.74]);
    ax3d.Color        = [0.04 0.04 0.10];
    ax3d.XColor       = [0.45 0.70 0.90];
    ax3d.YColor       = [0.45 0.70 0.90];
    ax3d.ZColor       = [0.45 0.70 0.90];
    ax3d.GridColor    = [0.18 0.32 0.48];
    ax3d.GridAlpha    = 0.30;
    ax3d.SortMethod   = 'childorder';   % skip depth-sort -> big speedup
    hold(ax3d,'on'); grid(ax3d,'on');
    xlabel(ax3d,'East (km)','Color',[0.6 0.85 1],'FontSize',8);
    ylabel(ax3d,'North (km)','Color',[0.6 0.85 1],'FontSize',8);
    zlabel(ax3d,'Alt (km)','Color',[0.6 0.85 1],'FontSize',8);
    title(ax3d,'6DOF Flat-Earth Ballistic Trajectory', ...
        'Color',[0.7 0.92 1],'FontSize',12,'FontWeight','bold');

    % --- Ground plane: single PATCH (no surf mesh overhead) ---
    patch(ax3d, xr([1 2 2 1]), yr([1 1 2 2]), [0 0 0 0], ...
        [0.06 0.20 0.10], ...
        'EdgeColor',[0.10 0.35 0.18],'FaceAlpha',0.75,'LineWidth',0.5);

    % --- Sparse ground grid (100 km spacing) ---
    gs = 100;
    for xi = (ceil(xr(1)/gs)*gs):gs:xr(2)
        line(ax3d,[xi xi],yr,[0 0],'Color',[0.12 0.38 0.20 0.45],'LineWidth',0.5);
    end
    for yi = (ceil(yr(1)/gs)*gs):gs:yr(2)
        line(ax3d,xr,[yi yi],[0 0],'Color',[0.12 0.38 0.20 0.45],'LineWidth',0.5);
    end

    % --- Ground shadow of trajectory ---
    plot3(ax3d,X_traj,Y_traj,zeros(n,1),'--','Color',[0.25 0.55 0.35 0.30],'LineWidth',1.0);

    % --- Static trajectory arc ---
    plot3(ax3d,X_traj,Y_traj,Z_traj,'--','Color',[0.25 0.60 0.95 0.40],'LineWidth',1.5);

    % --- Launch marker ---
    plot3(ax3d,0,0,0,'o','MarkerSize',10,'MarkerFaceColor',[0.2 0.92 0.45], ...
        'MarkerEdgeColor','w','LineWidth',1.2);
    text(ax3d,0,0,z_max*0.05,' LAUNCH','Color',[0.2 0.92 0.45],'FontWeight','bold','FontSize',8);

    % --- Target crosshair ---
    cs = z_max*0.025;
    line(ax3d,[X_target-cs X_target+cs],[Y_target Y_target],[0 0],'Color',[1 0.3 0.3],'LineWidth',2);
    line(ax3d,[X_target X_target],[Y_target-cs Y_target+cs],[0 0],'Color',[1 0.3 0.3],'LineWidth',2);
    plot3(ax3d,X_target,Y_target,0,'s','MarkerSize',9,'MarkerFaceColor',[1 0.3 0.3], ...
        'MarkerEdgeColor','w','LineWidth',1.2);
    text(ax3d,X_target,Y_target,z_max*0.05,' TARGET','Color',[1 0.3 0.3],'FontWeight','bold','FontSize',8);

    % --- Animated objects (ONLY these update each frame) ---
    trail_len = 10;
    h_trail  = plot3(ax3d,X_traj(1),Y_traj(1),Z_traj(1),'-','Color',[1 0.5 0.1],'LineWidth',2.5);
    h_rocket = plot3(ax3d,X_traj(1),Y_traj(1),Z_traj(1),'o', ...
        'MarkerSize',11,'MarkerFaceColor',[1 0.82 0.1],'MarkerEdgeColor','w','LineWidth',1.5);
    h_arrow  = quiver3(ax3d,X_traj(1),Y_traj(1),Z_traj(1), ...
        ax_vec(1,1),ax_vec(1,2),ax_vec(1,3), ...
        'Color',[1 0.92 0.3],'LineWidth',2,'MaxHeadSize',1.5,'AutoScale','off');

    % Single ambient light
    light(ax3d,'Position',[0 0 1]*1e4,'Style','infinite','Color',[0.7 0.8 1]);

    axis(ax3d,[xr(1) xr(2) yr(1) yr(2) -z_max*0.02 z_max]);
    daspect(ax3d,[1 1 1]);
    view(ax3d,[-35,22]);

    % ===================== RIGHT PANEL =====================
    % Altitude
    ax_alt = axes(fig5,'Position',[0.60 0.68 0.38 0.28]);
    ax_alt.Color=[0.05 0.05 0.12]; ax_alt.XColor=[0.5 0.7 0.9]; ax_alt.YColor=[0.5 0.7 0.9];
    ax_alt.GridColor=[0.2 0.3 0.5]; grid(ax_alt,'on'); hold(ax_alt,'on');
    fill(ax_alt,[t_arr;flipud(t_arr)],[alt_arr;zeros(n,1)],[0.1 0.3 0.6],'FaceAlpha',0.25,'EdgeColor','none');
    plot(ax_alt,t_arr,alt_arr,'-','Color',[0.3 0.7 1],'LineWidth',1.8);
    h_alt_dot = plot(ax_alt,t_arr(1),alt_arr(1),'o','MarkerSize',7,'MarkerFaceColor',[1 0.8 0.1],'MarkerEdgeColor','w');
    ylabel(ax_alt,'Alt (km)','Color',[0.6 0.8 1],'FontSize',7);
    title(ax_alt,'Altitude','Color',[0.8 0.95 1],'FontWeight','bold','FontSize',8);
    ax_alt.XTickLabel = {};

    % Velocity
    ax_vel = axes(fig5,'Position',[0.60 0.38 0.38 0.27]);
    ax_vel.Color=[0.05 0.05 0.12]; ax_vel.XColor=[0.5 0.7 0.9]; ax_vel.YColor=[0.5 0.7 0.9];
    ax_vel.GridColor=[0.2 0.3 0.5]; grid(ax_vel,'on'); hold(ax_vel,'on');
    fill(ax_vel,[t_arr;flipud(t_arr)],[v_arr;zeros(n,1)],[0.1 0.5 0.2],'FaceAlpha',0.25,'EdgeColor','none');
    plot(ax_vel,t_arr,v_arr,'-','Color',[0.2 0.95 0.5],'LineWidth',1.8);
    h_vel_dot = plot(ax_vel,t_arr(1),v_arr(1),'o','MarkerSize',7,'MarkerFaceColor',[1 0.8 0.1],'MarkerEdgeColor','w');
    ylabel(ax_vel,'Vel (m/s)','Color',[0.6 0.8 1],'FontSize',7);
    title(ax_vel,'Velocity','Color',[0.8 0.95 1],'FontWeight','bold','FontSize',8);
    ax_vel.XTickLabel = {};

    % 6DOF angles
    ax_6dof = axes(fig5,'Position',[0.60 0.08 0.38 0.27]);
    ax_6dof.Color=[0.05 0.05 0.12]; ax_6dof.XColor=[0.5 0.7 0.9]; ax_6dof.YColor=[0.5 0.7 0.9];
    ax_6dof.GridColor=[0.2 0.3 0.5]; grid(ax_6dof,'on'); hold(ax_6dof,'on');
    plot(ax_6dof,t_arr,pitch_arr,'-','Color',[1.0 0.6 0.2],'LineWidth',1.5,'DisplayName','Pitch');
    plot(ax_6dof,t_arr,yaw_arr,  '-','Color',[0.8 0.3 1.0],'LineWidth',1.5,'DisplayName','Yaw');
    plot(ax_6dof,t_arr,roll_arr, '-','Color',[0.3 0.9 0.9],'LineWidth',1.2,'DisplayName','Roll');
    h_p_dot = plot(ax_6dof,t_arr(1),pitch_arr(1),'o','MarkerSize',6,'MarkerFaceColor',[1 0.6 0.2],'MarkerEdgeColor','w');
    h_y_dot = plot(ax_6dof,t_arr(1),yaw_arr(1),  'o','MarkerSize',6,'MarkerFaceColor',[0.8 0.3 1],'MarkerEdgeColor','w');
    legend(ax_6dof,'TextColor',[0.8 0.9 1],'Color',[0.06 0.06 0.16],'FontSize',7,'Location','northeast');
    xlabel(ax_6dof,'Time (s)','Color',[0.6 0.8 1],'FontSize',7);
    ylabel(ax_6dof,'Angle (°)','Color',[0.6 0.8 1],'FontSize',7);
    title(ax_6dof,'6DOF Angles','Color',[0.8 0.95 1],'FontWeight','bold','FontSize',8);

    % ===================== HUD (compact, 2-row) =====================
    hud_ax = axes(fig5,'Position',[0.60 0.01 0.39 0.06]);
    axis(hud_ax,'off'); axis(hud_ax,[0 1 0 1]);
    patch(hud_ax,[0 1 1 0],[0 0 1 1],[0.04 0.06 0.14],'EdgeColor',[0.2 0.5 0.8],'LineWidth',1);
    c1=0.01; c2=0.34; c3=0.67;
    hud_t    = text(hud_ax,c1,0.72,'T+  0.0 s',   'Color',[0.9 0.9 0.5],'FontSize',8,'FontName','Courier New');
    hud_v    = text(hud_ax,c1,0.28,'VEL 0 m/s',   'Color',[0.3 1.0 0.5],'FontSize',8,'FontName','Courier New');
    hud_alt  = text(hud_ax,c2,0.72,'ALT 0 km',    'Color',[0.3 0.7 1.0],'FontSize',8,'FontName','Courier New');
    hud_dist = text(hud_ax,c2,0.28,'DST 0 km',    'Color',[0.8 0.5 1.0],'FontSize',8,'FontName','Courier New');
    hud_pit  = text(hud_ax,c3,0.72,'PCH 0 deg',   'Color',[1.0 0.65 0.2],'FontSize',8,'FontName','Courier New');
    hud_yaw  = text(hud_ax,c3,0.28,'YAW 0 deg',   'Color',[0.8 0.3 1.0],'FontSize',8,'FontName','Courier New');

    % ===================== CONTROLS =====================
    uicontrol(fig5,'Style','text','String','Speed:', ...
        'Units','normalized','Position',[0.01 0.005 0.05 0.03], ...
        'BackgroundColor',[0.04 0.04 0.10],'ForegroundColor',[0.7 0.9 1],'FontSize',8);
    spd_slider = uicontrol(fig5,'Style','slider','Min',1,'Max',15,'Value',4, ...
        'Units','normalized','Position',[0.07 0.008 0.13 0.025], ...
        'BackgroundColor',[0.15 0.25 0.45]);
    spd_lbl = uicontrol(fig5,'Style','text','String','4x', ...
        'Units','normalized','Position',[0.21 0.005 0.04 0.03], ...
        'BackgroundColor',[0.04 0.04 0.10],'ForegroundColor',[1 0.8 0.2],'FontSize',8);
    addlistener(spd_slider,'Value','PostSet', ...
        @(~,~) set(spd_lbl,'String',sprintf('%dx',round(spd_slider.Value))));

    btn_play    = uicontrol(fig5,'Style','pushbutton','String','▶ PLAY', ...
        'Units','normalized','Position',[0.26 0.003 0.07 0.038], ...
        'BackgroundColor',[0.10 0.55 0.25],'ForegroundColor','w','FontSize',9,'FontWeight','bold');
    btn_pause   = uicontrol(fig5,'Style','pushbutton','String','⏸ PAUSE', ...
        'Units','normalized','Position',[0.34 0.003 0.07 0.038], ...
        'BackgroundColor',[0.55 0.40 0.08],'ForegroundColor','w','FontSize',9,'FontWeight','bold');
    btn_restart = uicontrol(fig5,'Style','pushbutton','String','↺ RESET', ...
        'Units','normalized','Position',[0.42 0.003 0.07 0.038], ...
        'BackgroundColor',[0.50 0.10 0.10],'ForegroundColor','w','FontSize',9,'FontWeight','bold');

    annotation(fig5,'textbox',[0.01 0.94 0.57 0.05], ...
        'String','  ◈  6DOF BALLISTIC TRAJECTORY — FLAT-EARTH', ...
        'Color',[0.5 0.9 1],'FontSize',11,'FontWeight','bold', ...
        'EdgeColor',[0.2 0.5 0.8],'BackgroundColor',[0.04 0.06 0.14],'FontName','Courier New');

    % ===================== ANIMATION =====================
    anim_state = struct('running',false,'idx',1,'timer',[]);
    btn_play.Callback    = @(~,~) startAnim();
    btn_pause.Callback   = @(~,~) pauseAnim();
    btn_restart.Callback = @(~,~) restartAnim();

    % Pre-compute all HUD strings (avoids sprintf every frame)
    str_t    = arrayfun(@(x) sprintf('T+  %6.1f s',  x), t_arr,     'UniformOutput',false);
    str_v    = arrayfun(@(x) sprintf('VEL %6.0f m/s', x), v_arr,    'UniformOutput',false);
    str_alt  = arrayfun(@(x) sprintf('ALT %6.2f km',  x), alt_arr,  'UniformOutput',false);
    str_dist = arrayfun(@(x) sprintf('DST %6.1f km',  x), dist_arr, 'UniformOutput',false);
    str_pit  = arrayfun(@(x) sprintf('PCH %5.1f deg', x), pitch_arr,'UniformOutput',false);
    str_yaw  = arrayfun(@(x) sprintf('YAW %5.1f deg', x), yaw_arr,  'UniformOutput',false);

    function startAnim()
        if ~isempty(anim_state.timer) && isvalid(anim_state.timer)
            stop(anim_state.timer); delete(anim_state.timer);
        end
        anim_state.running = true;
        spd = round(spd_slider.Value);
        anim_state.timer = timer('ExecutionMode','fixedRate', ...
            'Period', max(0.03, 0.10/spd), ...
            'TimerFcn', @(~,~) stepAnim());
        start(anim_state.timer);
    end

    function pauseAnim()
        anim_state.running = false;
        if ~isempty(anim_state.timer) && isvalid(anim_state.timer)
            stop(anim_state.timer);
        end
    end

    function restartAnim()
        pauseAnim();
        anim_state.idx = 1;
        updateFrame(1);
    end

    function stepAnim()
        if ~isvalid(fig5), pauseAnim(); return; end
        i = anim_state.idx;
        if i > n, pauseAnim(); return; end
        try
            updateFrame(i);
        catch
            pauseAnim(); return;
        end
        anim_state.idx = min(n, anim_state.idx + round(spd_slider.Value));
    end

    function updateFrame(i)
        % 3D: only 3 graphic objects touched
        set(h_rocket,'XData',X_traj(i),'YData',Y_traj(i),'ZData',Z_traj(i));

        i0 = max(1, i-trail_len+1);
        set(h_trail,'XData',X_traj(i0:i),'YData',Y_traj(i0:i),'ZData',Z_traj(i0:i));

        set(h_arrow,'XData',X_traj(i),'YData',Y_traj(i),'ZData',Z_traj(i), ...
            'UData',ax_vec(i,1),'VData',ax_vec(i,2),'WData',ax_vec(i,3));

        % Mini-plot cursors
        set(h_alt_dot,'XData',t_arr(i),'YData',alt_arr(i));
        set(h_vel_dot,'XData',t_arr(i),'YData',v_arr(i));
        set(h_p_dot,  'XData',t_arr(i),'YData',pitch_arr(i));
        set(h_y_dot,  'XData',t_arr(i),'YData',yaw_arr(i));

        % HUD from pre-built strings
        set(hud_t,   'String', str_t{i});
        set(hud_v,   'String', str_v{i});
        set(hud_alt, 'String', str_alt{i});
        set(hud_dist,'String', str_dist{i});
        set(hud_pit, 'String', str_pit{i});
        set(hud_yaw, 'String', str_yaw{i});

        % Gentle camera follow
        view(ax3d, yaw_arr(i)-40, 18 + 8*(alt_arr(i)/max(alt_arr)));

        drawnow limitrate;
    end

    updateFrame(1);
end