function window3(selectedCategory, selectedRocket, specs)
    % ── Range data ───────────────────────────────────────────────────
    ranges = containers.Map;
    ranges('Short-Range Ballistic Missile (SRBM)')         = 1000;
    ranges('Medium-Range Ballistic Missile (MRBM)')        = 3500;
    ranges('Intermediate-Range Ballistic Missile (IRBM)')  = 5500;
    ranges('Intercontinental Ballistic Missile (ICBM)')    = 12000;
    max_range = ranges(selectedCategory);

    % ── Target coordinates ───────────────────────────────────────────
    target_coords = containers.Map;
    target_coords('Mediterranean Sea (Alexandria)') = struct('lon',29.9, 'lat',31.2);
    target_coords('Mediterranean Sea (Port Said)')  = struct('lon',32.3, 'lat',31.3);
    target_coords('Red Sea (Gulf of Suez)')         = struct('lon',32.5, 'lat',29.9);
    target_coords('Red Sea (Hurghada)')             = struct('lon',33.8, 'lat',27.3);
    target_coords('Indian Ocean (Aden)')            = struct('lon',45.0, 'lat',12.8);
    target_coords('Indian Ocean (Arabian Sea)')     = struct('lon',67.0, 'lat',20.0);
    target_coords('Atlantic Ocean (Gibraltar)')     = struct('lon',-5.3, 'lat',36.1);
    target_coords('New york,USA')                   = struct('lon',-74.0,'lat',40.7);
    target_coords('Tokyo ,Japan')                   = struct('lon',139.7,'lat',35.7);

    category_targets = containers.Map;
    category_targets('Short-Range Ballistic Missile (SRBM)')        = {'Mediterranean Sea (Alexandria)','Mediterranean Sea (Port Said)','Red Sea (Gulf of Suez)'};
    category_targets('Medium-Range Ballistic Missile (MRBM)')       = {'Red Sea (Hurghada)','Indian Ocean (Aden)'};
    category_targets('Intermediate-Range Ballistic Missile (IRBM)') = {'Indian Ocean (Arabian Sea)','Atlantic Ocean (Gibraltar)'};
    category_targets('Intercontinental Ballistic Missile (ICBM)')   = {'New york,USA','Tokyo ,Japan'};

    if isKey(category_targets, selectedCategory)
        reachable_seas = category_targets(selectedCategory);
    else
        reachable_seas = {'No targets defined'};
    end

    cairo_coords = struct('lon',31.24,'lat',30.4);

    % ── Colour palette ────────────────────────────────────────────────
    C.bg       = [0.08 0.10 0.13];
    C.panel    = [0.11 0.14 0.18];
    C.accent   = [0.95 0.65 0.10];
    C.text     = [0.90 0.92 0.95];
    C.sub      = [0.50 0.55 0.62];
    C.border   = [0.20 0.26 0.33];
    C.btnGo    = [0.18 0.55 0.34];
    C.statBg   = [0.09 0.12 0.16];
    C.danger   = [0.80 0.18 0.18];
    C.green    = [0.20 0.78 0.45];

    % ── Figure ───────────────────────────────────────────────────────
    fig3 = uifigure( ...
        'Name',     'BMDS — Target Selection', ...
        'Position', [240 140 780 560], ...
        'Color',    C.bg, ...
        'Resize',   'on');

    % ── Top header bar ───────────────────────────────────────────────
    uipanel(fig3,'Position',[0 520 780 40],'BackgroundColor',C.accent,'BorderType','none');
    uilabel(fig3,'Text','⬡  BMDS  |  TARGET DESIGNATION','Position',[20 524 400 28],...
        'FontSize',10,'FontWeight','bold','FontColor',C.bg);
    uilabel(fig3,'Text',['ROCKET: ' upper(selectedRocket)],'Position',[200 524 560 28],...
        'FontSize',9,'FontWeight','bold','FontColor',[0.15 0.08 0.02],'HorizontalAlignment','right');

    % Left accent strip
    uipanel(fig3,'Position',[0 0 4 520],'BackgroundColor',C.accent,'BorderType','none');

    % ── Breadcrumb ───────────────────────────────────────────────────
    uilabel(fig3,'Text',['✓ ' selectedCategory '  ›  ✓ ' selectedRocket '  ›  STEP 3: SELECT TARGET'],...
        'Position',[20 490 750 20],'FontSize',9,'FontColor',C.sub);
    uipanel(fig3,'Position',[20 486 740 1],'BackgroundColor',C.border,'BorderType','none');

    % ── Title ────────────────────────────────────────────────────────
    uilabel(fig3,'Text','STEP 3  —  TARGET DESIGNATION',...
        'Position',[20 450 500 28],'FontSize',15,'FontWeight','bold','FontColor',C.accent);
    uilabel(fig3,'Text','Select an authorised strike target within category operational range.',...
        'Position',[20 430 600 18],'FontSize',10,'FontColor',C.sub);

    % ── Mission summary strip ─────────────────────────────────────────
    uipanel(fig3,'Position',[20 395 740 30],'BackgroundColor',C.statBg,'BorderType','none');
    uilabel(fig3,'Text',sprintf('■ CATEGORY: %s   ■ ROCKET: %s   ■ MAX RANGE: %d km', ...
        selectedCategory, selectedRocket, max_range),...
        'Position',[30 397 720 24],'FontSize',9,'FontWeight','bold','FontColor',C.accent);

    % ── Left panel: target list ───────────────────────────────────────
    uipanel(fig3,'Position',[20 60 380 328],'BackgroundColor',C.panel,...
        'BorderType','line','HighlightColor',C.border);
    uilabel(fig3,'Text','AUTHORISED TARGETS','Position',[30 373 300 18],...
        'FontSize',9,'FontWeight','bold','FontColor',C.sub);

    lb_seas = uilistbox(fig3, ...
        'Items',           reachable_seas, ...
        'Position',        [30 68 360 295], ...
        'FontSize',        12, ...
        'BackgroundColor', C.statBg, ...
        'FontColor',       C.text);

    % ── Right panel: target info ──────────────────────────────────────
    uipanel(fig3,'Position',[420 220 340 168],'BackgroundColor',C.panel,...
        'BorderType','line','HighlightColor',C.border);
    uilabel(fig3,'Text','TARGET COORDINATES','Position',[430 375 300 18],...
        'FontSize',9,'FontWeight','bold','FontColor',C.sub);

    % Target info labels
    tgt_name_lbl = uilabel(fig3,'Text','—',...
        'Position',[430 348 320 22],'FontSize',13,'FontWeight','bold','FontColor',C.text);
    tgt_lon_lbl = uilabel(fig3,'Text','LONGITUDE: —',...
        'Position',[430 318 320 18],'FontSize',10,'FontColor',C.sub);
    tgt_lat_lbl = uilabel(fig3,'Text','LATITUDE:  —',...
        'Position',[430 296 320 18],'FontSize',10,'FontColor',C.sub);

    uipanel(fig3,'Position',[430 288 320 1],'BackgroundColor',C.border,'BorderType','none');

    tgt_dist_lbl   = uilabel(fig3,'Text','DISTANCE FROM LAUNCH: — km',...
        'Position',[430 265 320 18],'FontSize',10,'FontColor',C.green,'FontWeight','bold');
    tgt_bear_lbl   = uilabel(fig3,'Text','BEARING: —°',...
        'Position',[430 244 320 18],'FontSize',10,'FontColor',C.green,'FontWeight','bold');
    tgt_status_lbl = uilabel(fig3,'Text','STATUS: —',...
        'Position',[430 222 320 18],'FontSize',10,'FontColor',C.text);

    % ── Range gauge ──────────────────────────────────────────────────
    uipanel(fig3,'Position',[420 60 340 150],'BackgroundColor',C.panel,...
        'BorderType','line','HighlightColor',C.border);
    uilabel(fig3,'Text','RANGE UTILISATION','Position',[430 196 300 18],...
        'FontSize',9,'FontWeight','bold','FontColor',C.sub);

    % Background bar
    uipanel(fig3,'Position',[430 170 310 16],'BackgroundColor',C.border,'BorderType','none');
    % Fill bar (updated dynamically)
    fill_bar = uipanel(fig3,'Position',[430 170 1 16],'BackgroundColor',C.green,'BorderType','none');

    pct_lbl = uilabel(fig3,'Text','0%  of max range',...
        'Position',[430 148 310 18],'FontSize',9,'FontColor',C.sub);

    % Info note
    uipanel(fig3,'Position',[430 100 310 1],'BackgroundColor',C.border,'BorderType','none');
    uilabel(fig3,'Text', ...
        sprintf('Launch point: Cairo (%.1f°N, %.1f°E)\nMax range of selected system: %d km', ...
            cairo_coords.lat, cairo_coords.lon, max_range), ...
        'Position',[430 66 310 32],'FontSize',9,'FontColor',C.sub,'WordWrap','on');

    % Initial fill
    updateTargetInfo(lb_seas.Value);

    % Update on selection change
    lb_seas.ValueChangedFcn = @(~,~) updateTargetInfo(lb_seas.Value);

    % ── Progress ─────────────────────────────────────────────────────
    uilabel(fig3,'Text','✓ STEP 1  ✓ STEP 2  ● STEP 3 of 3',...
        'Position',[20 32 300 18],'FontSize',9,'FontColor',C.accent);

    % ── Buttons ──────────────────────────────────────────────────────
    uibutton(fig3,'Text','‹ BACK','Position',[20 8 100 28],...
        'FontSize',10,'BackgroundColor',C.statBg,'FontColor',C.sub,...
        'ButtonPushedFcn',@(~,~) delete(fig3));

    btn = uibutton(fig3,'Text','CALCULATE TRAJECTORY  ›',...
        'Position',[530 8 230 32],'FontSize',11,'FontWeight','bold',...
        'BackgroundColor',C.btnGo,'FontColor','white');

    % ── Updated callback: passes target name and rocket name into window4
    btn.ButtonPushedFcn = @(~,~) launchWindow4( ...
        specs, cairo_coords, target_coords, lb_seas, selectedRocket);

    % ── Status bar ───────────────────────────────────────────────────
    uipanel(fig3,'Position',[0 0 780 8],'BackgroundColor',C.accent,'BorderType','none');

    % ════════════════════════════════════════════════════════════════
    % NESTED HELPER — launch window4 with name fields attached
    % ════════════════════════════════════════════════════════════════
    function launchWindow4(sp, cairo, tgt_map, lb, rkt_name)
        tname    = lb.Value;
        tc       = tgt_map(tname);
        % Attach names so window4 can build its lookup key
        tc.name  = tname;
        sp.name  = rkt_name;
        window4(sp, cairo, tc);
    end

    % ════════════════════════════════════════════════════════════════
    % NESTED UPDATE FUNCTION
    % ════════════════════════════════════════════════════════════════
    function updateTargetInfo(tname)
        if ~isKey(target_coords, tname), return; end
        tc = target_coords(tname);

        tgt_name_lbl.Text = tname;
        tgt_lon_lbl.Text  = sprintf('LONGITUDE:  %.4f°', tc.lon);
        tgt_lat_lbl.Text  = sprintf('LATITUDE:   %.4f°', tc.lat);

        % Great-circle distance
        RE = 6371;
        lat1 = deg2rad(cairo_coords.lat);
        lon1 = deg2rad(cairo_coords.lon);
        lat2 = deg2rad(tc.lat);
        lon2 = deg2rad(tc.lon);
        dlat = lat2-lat1; dlon = lon2-lon1;
        aa = sin(dlat/2)^2 + cos(lat1)*cos(lat2)*sin(dlon/2)^2;
        dist_km = RE * 2 * atan2(sqrt(aa),sqrt(1-aa));

        % Bearing
        y_b = sin(lon2-lon1)*cos(lat2);
        x_b = cos(lat1)*sin(lat2) - sin(lat1)*cos(lat2)*cos(lon2-lon1);
        bearing = mod(rad2deg(atan2(y_b,x_b))+360,360);

        tgt_dist_lbl.Text = sprintf('DISTANCE FROM LAUNCH:  %.1f km', dist_km);
        tgt_bear_lbl.Text = sprintf('BEARING:  %.1f°', bearing);

        pct   = min(dist_km / max_range, 1);
        bar_w = max(2, round(310 * pct));
        fill_bar.Position = [430 170 bar_w 16];
        pct_lbl.Text = sprintf('%.0f%%  of max range  (%.0f / %d km)', pct*100, dist_km, max_range);

        if dist_km <= max_range
            fill_bar.BackgroundColor = C.green;
            tgt_status_lbl.Text      = 'STATUS: ✓ WITHIN RANGE';
            tgt_status_lbl.FontColor = C.green;
        else
            fill_bar.BackgroundColor = C.danger;
            tgt_status_lbl.Text      = 'STATUS: ✗ OUT OF RANGE';
            tgt_status_lbl.FontColor = C.danger;
        end
    end
end