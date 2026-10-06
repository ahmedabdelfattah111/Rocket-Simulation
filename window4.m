function window4(specs, cairo_coords, target_coords)
    % ── CONSTANTS ─────────────────────────────────────────────────────
    G_CONST        = 9.80665;        % surface gravity — used ONLY for Isp/exhaust_vel
    GM             = 3.986004418e14; % Earth gravitational parameter (m^3/s^2)
    ATM_PRESSURE   = 101.325;
    RE_M           = 6371000;
    GAS_PRESSURE   = 101.325;
    R_SPECIFIC     = 287.05;

    % ── Great-circle distance ─────────────────────────────────────────
    lat1 = deg2rad(cairo_coords.lat);   lon1 = deg2rad(cairo_coords.lon);
    lat2 = deg2rad(target_coords.lat);  lon2 = deg2rad(target_coords.lon);
    dlat = lat2-lat1;  dlon = lon2-lon1;
    a    = sin(dlat/2)^2 + cos(lat1)*cos(lat2)*sin(dlon/2)^2;
    trajectory_distance_km = RE_M * 2 * atan2(sqrt(a),sqrt(1-a)) / 1000;

    % ── Optimal heading (always computed from geometry) ───────────────
    psi_optimal = calculateBearing(cairo_coords.lat, cairo_coords.lon, ...
                                   target_coords.lat, target_coords.lon);

    % ════════════════════════════════════════════════════════════════
    %  >>>  MANUAL DEFAULT LOOKUP TABLE  <<<
    %
    %  Key format:  'RocketName|TargetName'
    %  Values:      [fuel_mass_kg,  heading_angle_deg,  launch_angle_gamma_deg]
    %
    %  HOW TO USE:
    %    1. Add a new row for each rocket+target pair you want to control.
    %    2. The key is case-sensitive and must match exactly the names used
    %       in window2 (rocket) and window3 (target).
    %    3. Leave the fallback section below untouched — it activates
    %       automatically for any combination NOT found in this table.
    %
    %  EXAMPLE ENTRY (fill in the three numbers):
    %    manual_defaults('Iskander-M|Mediterranean Sea (Alexandria)') = [2700, 307.0, 45.0];
    %    manual_defaults('DF-15|Red Sea (Gulf of Suez)')              = [9400, 135.0, 42.0];
    %
    % ────────────────────────────────────────────────────────────────
    manual_defaults = containers.Map('KeyType','char','ValueType','any');

    % ── SRBM rockets ─────────────────────────────────────────────────
    manual_defaults('Iskander-M|Mediterranean Sea (Alexandria)') = [3912, 304.7, 80.6];
    manual_defaults('Iskander-M|Mediterranean Sea (Port Said)')  = [3545, 45.3,  80];
    manual_defaults('Iskander-M|Red Sea (Gulf of Suez)')         = [3400, 114.6, 80];

    manual_defaults('DF-15|Mediterranean Sea (Alexandria)')      = [3100, 305,   88];
    manual_defaults('DF-15|Mediterranean Sea (Port Said)')       = [2985, 45.5,  88];
    manual_defaults('DF-15|Red Sea (Gulf of Suez)')              = [2905, 114.6, 88];

    manual_defaults('KN-23|Mediterranean Sea (Alexandria)')      = [2850, 305,   88];
    manual_defaults('KN-23|Mediterranean Sea (Port Said)')       = [2750, 45.5,  88];
    manual_defaults('KN-23|Red Sea (Gulf of Suez)')              = [2680, 114.4, 88.3];

    manual_defaults('Fateh-110|Mediterranean Sea (Alexandria)')  = [3070, 305,   89.1];
    manual_defaults('Fateh-110|Mediterranean Sea (Port Said)')   = [2925, 45.5,  89.1];
    manual_defaults('Fateh-110|Red Sea (Gulf of Suez)')          = [2850, 114.4, 89.1];

    manual_defaults('Ghaznavi|Mediterranean Sea (Alexandria)')   = [3850, 305,   89.3];
    manual_defaults('Ghaznavi|Mediterranean Sea (Port Said)')    = [3665, 45.5,  89.3];
    manual_defaults('Ghaznavi|Red Sea (Gulf of Suez)')           = [3580, 114.4, 89.3];

    % ── MRBM rockets ─────────────────────────────────────────────────
    manual_defaults('Shahab-3|Red Sea (Hurghada)')               = [14995, 144, 84.8];
    manual_defaults('Shahab-3|Indian Ocean (Aden)')              = [27000, 144, 70];

    manual_defaults('Musudan|Red Sea (Hurghada)')                = [27000, 144, 70];
    manual_defaults('Musudan|Indian Ocean (Aden)')               = [25500, 144, 70];

    manual_defaults('Ghauri I/II|Red Sea (Hurghada)')            = [27750, 144, 75];
    manual_defaults('Ghauri I/II|Indian Ocean (Aden)')           = [28000, 144, 71];

    manual_defaults('Shaheen-II|Red Sea (Hurghada)')             = [14855, 144, 45];
    manual_defaults('Shaheen-II|Indian Ocean (Aden)')            = [29050, 144, 65];

    manual_defaults('Agni-II|Red Sea (Hurghada)')                = [8033,  144, 70];
    manual_defaults('Agni-II|Indian Ocean (Aden)')               = [22090, 144, 65];

    % ── IRBM rockets ─────────────────────────────────────────────────
    manual_defaults('Agni-IV|Indian Ocean (Arabian Sea)')        = [19300, 107.9, 82];
    manual_defaults('Agni-IV|Atlantic Ocean (Gibraltar)')        = [22000, 280.8, 74];

    manual_defaults('Hwasong-12|Indian Ocean (Arabian Sea)')     = [27950, 108,   60];
    manual_defaults('Hwasong-12|Atlantic Ocean (Gibraltar)')     = [23890, 280,   76];

    manual_defaults('Hyunmoo-5|Indian Ocean (Arabian Sea)')      = [37533, 108,   56];
    manual_defaults('Hyunmoo-5|Atlantic Ocean (Gibraltar)')      = [39955, 279.9, 51];

    manual_defaults('Shahab-5|Indian Ocean (Arabian Sea)')       = [39924, 107.9, 74];
    manual_defaults('Shahab-5|Atlantic Ocean (Gibraltar)')       = [48594, 81,    80];

    manual_defaults('Shaheen-III|Indian Ocean (Arabian Sea)')    = [39924, 107.9, 79];
    manual_defaults('Shaheen-III|Atlantic Ocean (Gibraltar)')    = [47594, 280,   83];

    % ── ICBM rockets ─────────────────────────────────────────────────
    manual_defaults('Minuteman III|New york,USA')                = [NaN, NaN, NaN];
    manual_defaults('Minuteman III|Tokyo ,Japan')                = [NaN, NaN, NaN];

    manual_defaults('RS-24 Yars|New york,USA')                   = [NaN, NaN, NaN];
    manual_defaults('RS-24 Yars|Tokyo ,Japan')                   = [NaN, NaN, NaN];

    manual_defaults('Shahab-6|New york,USA')                     = [NaN, NaN, NaN];
    manual_defaults('Shahab-6|Tokyo ,Japan')                     = [NaN, NaN, NaN];

    manual_defaults('RS-26 Rubezh|New york,USA')                 = [NaN, NaN, NaN];
    manual_defaults('RS-26 Rubezh|Tokyo ,Japan')                 = [NaN, NaN, NaN];

    manual_defaults('Hwasong-15/17|New york,USA')                = [NaN, NaN, NaN];
    manual_defaults('Hwasong-15/17|Tokyo ,Japan')                = [NaN, NaN, NaN];

    % ════════════════════════════════════════════════════════════════
    %  LOOKUP — resolve defaults for current rocket + target
    % ════════════════════════════════════════════════════════════════
    lookup_key = buildLookupKey(specs, target_coords, manual_defaults);

    if ~isempty(lookup_key) && isKey(manual_defaults, lookup_key)
        row = manual_defaults(lookup_key);
        fuel_default  = resolveValue(row(1), getFuelMass(specs.dry_mass, specs.warhead_mass));
        psi_default   = resolveValue(row(2), psi_optimal);
        gamma_default = resolveValue(row(3), computeOptimalGamma(specs, trajectory_distance_km, ...
                            resolveValue(row(1), getFuelMass(specs.dry_mass, specs.warhead_mass)), G_CONST));
        src_tag       = 'MANUAL';
    else
        fuel_default  = getFuelMass(specs.dry_mass, specs.warhead_mass);
        psi_default   = psi_optimal;
        gamma_default = computeOptimalGamma(specs, trajectory_distance_km, fuel_default, G_CONST);
        src_tag       = 'AUTO';
    end

    % ── Colour palette ────────────────────────────────────────────────
    C.bg      = [0.08 0.10 0.13];
    C.panel   = [0.11 0.14 0.18];
    C.accent  = [0.95 0.65 0.10];
    C.text    = [0.90 0.92 0.95];
    C.sub     = [0.50 0.55 0.62];
    C.border  = [0.20 0.26 0.33];
    C.statBg  = [0.09 0.12 0.16];
    C.green   = [0.18 0.55 0.34];
    C.greenHi = [0.20 0.78 0.45];
    C.blue    = [0.12 0.40 0.75];
    C.blueHi  = [0.35 0.65 1.00];
    C.danger  = [0.80 0.18 0.18];

    % ════════════════════════════════════════════════════════════════
    % FIGURE
    % ════════════════════════════════════════════════════════════════
    fig4 = uifigure( ...
        'Name',     'BMDS — 3D Ballistic Trajectory Engine  [RK4 + g(h)]', ...
        'Position', [30 0 1180 760], ...
        'Color',    C.bg, ...
        'Resize',   'on');

    % ── Header bar ───────────────────────────────────────────────────
    uipanel(fig4,'Position',[0 720 1180 40],'BackgroundColor',C.accent,'BorderType','none');
    uilabel(fig4,'Text','⬡  BMDS  |  TRAJECTORY SIMULATION ENGINE  [RK4 + g(h)]',...
        'Position',[20 724 560 28],'FontSize',10,'FontWeight','bold','FontColor',C.bg);
    uilabel(fig4,'Text',sprintf('LAUNCH: %.2f°N %.2f°E   —   TARGET: %.2f°N %.2f°E', ...
        cairo_coords.lat,cairo_coords.lon,target_coords.lat,target_coords.lon),...
        'Position',[400 724 760 28],'FontSize',9,'FontWeight','bold',...
        'FontColor',[0.15 0.08 0.02],'HorizontalAlignment','right');

    uipanel(fig4,'Position',[0 0 4 720],'BackgroundColor',C.accent,'BorderType','none');

    % ── Breadcrumb ───────────────────────────────────────────────────
    uilabel(fig4,'Text','✓ CATEGORY  ›  ✓ ROCKET  ›  ✓ TARGET  ›  ● STEP 4: SIMULATION',...
        'Position',[20 690 700 20],'FontSize',9,'FontColor',C.sub);
    uipanel(fig4,'Position',[20 686 1140 1],'BackgroundColor',C.border,'BorderType','none');

    uilabel(fig4,'Text','STEP 4  —  TRAJECTORY SIMULATION',...
        'Position',[20 653 600 28],'FontSize',15,'FontWeight','bold','FontColor',C.accent);

    % ════════════════════════════════════════════════════════════════
    % LEFT COLUMN  (scrollable)
    % ════════════════════════════════════════════════════════════════
    main_p = uipanel(fig4, ...
        'Position',        [20 40 430 606], ...
        'Scrollable',      'on', ...
        'BackgroundColor', C.bg, ...
        'BorderType',      'none');

    inner_h = 1120;

    % ── A: Rocket Specifications ──────────────────────────────────────
    sec_specs_y = inner_h - 30;
    mk_section(main_p, 'A  ROCKET SPECIFICATIONS', sec_specs_y, C);
    spec_rows = { ...
        'Dry Mass',         specs.dry_mass,        'kg';   ...
        'Warhead Mass',     specs.warhead_mass,     'kg';   ...
        'Specific Impulse', specs.isp,              's';    ...
        'Diameter',         specs.diameter,         'm';    ...
        'Mass Flow Rate',   specs.mass_flow_rate,   'kg/s'  ...
    };
    for k = 1:size(spec_rows,1)
        mk_ro_row(main_p, spec_rows{k,1}, spec_rows{k,2}, spec_rows{k,3}, ...
            sec_specs_y - 28 - (k-1)*34, C);
    end

    % ── B: Coordinates & Heading ──────────────────────────────────────
    sec_coord_y = sec_specs_y - 28 - 5*34 - 20;
    mk_section(main_p, 'B  COORDINATES & HEADING', sec_coord_y, C);
    coord_rows = { ...
        'Launch Longitude', cairo_coords.lon,   '°E'; ...
        'Launch Latitude',  cairo_coords.lat,   '°N'; ...
        'Target Longitude', target_coords.lon,  '°E'; ...
        'Target Latitude',  target_coords.lat,  '°N'  ...
    };
    for k = 1:size(coord_rows,1)
        mk_ro_row(main_p, coord_rows{k,1}, coord_rows{k,2}, coord_rows{k,3}, ...
            sec_coord_y - 28 - (k-1)*34, C);
    end

    pill_y = sec_coord_y - 28 - 4*34 - 12;
    uipanel(main_p,'Position',[10 pill_y 195 28],'BackgroundColor',C.statBg,'BorderType','none');
    uilabel(main_p,'Text',sprintf('  DIST  %.1f km', trajectory_distance_km),...
        'Position',[12 pill_y 190 28],'FontSize',10,'FontWeight','bold','FontColor',C.greenHi);
    uipanel(main_p,'Position',[215 pill_y 195 28],'BackgroundColor',C.statBg,'BorderType','none');
    uilabel(main_p,'Text',sprintf('  HDG  %.1f °', psi_optimal),...
        'Position',[217 pill_y 190 28],'FontSize',10,'FontWeight','bold','FontColor',C.blueHi);

    % ── C: Mission Parameters ─────────────────────────────────────────
    sec_mis_y = pill_y - 20;
    mk_section(main_p, 'C  MISSION PARAMETERS', sec_mis_y, C);

    row_y = sec_mis_y - 28;

    if strcmp(src_tag,'MANUAL')
        tag_color = C.greenHi;
        tag_str   = ['⬤  DEFAULTS: MANUAL  |  KEY: ' lookup_key];
    else
        tag_color = C.sub;
        tag_str   = '◌  DEFAULTS: AUTO-CALCULATED  (no manual entry found)';
    end
    uilabel(main_p,'Text', tag_str,...
        'Position',[10 row_y 400 20],'FontSize',8,'FontColor',tag_color,'WordWrap','on');

    row_y = row_y - 28;

    uilabel(main_p,'Text','Heading Angle (ψ)°',...
        'Position',[10 row_y 200 22],'FontSize',10,'FontColor',C.sub);
    psi_ent = uieditfield(main_p,'numeric','Value', psi_default,...
        'Position',[210 row_y 200 26],...
        'BackgroundColor',C.panel,'FontColor',C.accent,'FontSize',11,'FontWeight','bold');

    row_y = row_y - 34;

    uilabel(main_p,'Text','Ambient Temperature (K)',...
        'Position',[10 row_y 200 22],'FontSize',10,'FontColor',C.sub);
    temp_ent = uieditfield(main_p,'numeric','Value',300,...
        'Position',[210 row_y 200 26],...
        'BackgroundColor',C.panel,'FontColor',C.text,'FontSize',11);

    row_y = row_y - 34;

    uilabel(main_p,'Text','Fuel Mass (kg)',...
        'Position',[10 row_y 200 22],'FontSize',10,'FontColor',C.sub);
    fuel_ent = uieditfield(main_p,'numeric','Value', fuel_default,...
        'Position',[210 row_y 200 26],...
        'BackgroundColor',C.panel,'FontColor',C.text,'FontSize',11);

    row_y = row_y - 34;

    uilabel(main_p,'Text','Launch Angle (γ)°',...
        'Position',[10 row_y 200 22],'FontSize',10,'FontColor',C.sub);
    gamma_ent = uieditfield(main_p,'numeric','Value', gamma_default,...
        'Position',[210 row_y 200 26],...
        'BackgroundColor',C.panel,'FontColor',C.accent,'FontSize',11,'FontWeight','bold');
    uilabel(main_p,'Text',['source: ' src_tag ' (editable)'],...
        'Position',[210 row_y-16 200 16],'FontSize',8,'FontColor',tag_color);

    row_y = row_y - 34;

    recalc_btn = uibutton(main_p,'Text','↺  RECALCULATE OPTIMAL γ FROM FUEL',...
        'Position',[10 row_y 400 26],...
        'BackgroundColor',C.statBg,'FontColor',C.sub,...
        'FontWeight','bold','FontSize',9);
    recalc_btn.ButtonPushedFcn = @(~,~) recalcGamma(gamma_ent, fuel_ent, ...
        specs, trajectory_distance_km, G_CONST);

    % ── D: Action buttons ─────────────────────────────────────────────
    btn_run_y = row_y - 56;

    run_btn = uibutton(main_p,'Text','▶  RUN TRAJECTORY SIMULATION',...
        'Position',[10 btn_run_y 400 42],...
        'BackgroundColor',C.green,'FontColor','white','FontWeight','bold','FontSize',13);

    globe_btn = uibutton(main_p,'Text','◉  LAUNCH 3D GLOBE VIEW',...
        'Position',[10 btn_run_y-56 400 42],...
        'BackgroundColor',C.blue,'FontColor','white','FontWeight','bold','FontSize',11,...
        'Enable','off');

    % ── E: Summary box ────────────────────────────────────────────────
    sec_results_y = btn_run_y - 56 - 30;
    summary_y     = sec_results_y - 24 - 155;
    mk_section(main_p,'E  SIMULATION RESULTS', sec_results_y, C);
    uipanel(main_p,'Position',[10 summary_y 400 150],...
        'BackgroundColor',C.statBg,'BorderType','line','HighlightColor',C.border);
    summary_label = uilabel(main_p,'Text','Awaiting simulation run...',...
        'Position',[18 summary_y+6 384 138],...
        'FontSize',10,'FontColor',C.sub,'VerticalAlignment','top','WordWrap','on');

    % ════════════════════════════════════════════════════════════════
    % MIDDLE COLUMN: stat tiles
    % ════════════════════════════════════════════════════════════════
    mid_x = 465;
    tile_titles = {'MAX ALTITUDE','TOTAL FLIGHT TIME','IMPACT VELOCITY','ACCURACY'};
    tile_units  = {'km','s','m/s','%'};
    tile_icons  = {'▲','◷','⚡','◎'};
    tile_y      = [570 460 350 240];
    tile_vals   = gobjects(1,4);
    for k = 1:4
        uipanel(fig4,'Position',[mid_x tile_y(k) 228 96],...
            'BackgroundColor',C.panel,'BorderType','line','HighlightColor',C.border);
        uilabel(fig4,'Text',[tile_icons{k} '  ' tile_titles{k}],...
            'Position',[mid_x+10 tile_y(k)+72 208 18],...
            'FontSize',8,'FontWeight','bold','FontColor',C.sub);
        tile_vals(k) = uilabel(fig4,'Text','—',...
            'Position',[mid_x+10 tile_y(k)+26 208 42],...
            'FontSize',26,'FontWeight','bold','FontColor',C.accent);
        uilabel(fig4,'Text',tile_units{k},...
            'Position',[mid_x+10 tile_y(k)+8 208 18],'FontSize',9,'FontColor',C.sub);
    end

    uipanel(fig4,'Position',[mid_x 160 228 68],'BackgroundColor',C.statBg,'BorderType','none');
    uilabel(fig4,'Text','FLIGHT PHASE','Position',[mid_x+10 218 208 14],...
        'FontSize',8,'FontWeight','bold','FontColor',C.sub);
    phase_lbl = uilabel(fig4,'Text','STANDBY','Position',[mid_x+10 176 208 38],...
        'FontSize',16,'FontWeight','bold','FontColor',C.border);

    uipanel(fig4,'Position',[mid_x 80 228 68],'BackgroundColor',C.statBg,'BorderType','none');
    uilabel(fig4,'Text','PEAK MACH NUMBER','Position',[mid_x+10 138 208 14],...
        'FontSize',8,'FontWeight','bold','FontColor',C.sub);
    mach_lbl = uilabel(fig4,'Text','—','Position',[mid_x+10 96 208 38],...
        'FontSize',18,'FontWeight','bold','FontColor',C.blueHi);

    % ════════════════════════════════════════════════════════════════
    % RIGHT COLUMN: data table
    % ════════════════════════════════════════════════════════════════
    tbl_x = 710;
    uipanel(fig4,'Position',[tbl_x 648 460 20],'BackgroundColor',C.statBg,'BorderType','none');
    uilabel(fig4,'Text','  TELEMETRY LOG  —  10 s SAMPLE INTERVAL',...
        'Position',[tbl_x+4 648 456 18],'FontSize',9,'FontWeight','bold','FontColor',C.sub);
    colNames = {'Time (s)','Vel (m/s)','Alt (km)','Dist (km)',...
                'Lat °','Lon °','Angle °','Thrust (N)','Drag (N)','Mass (kg)'};
    res_table = uitable(fig4,'ColumnName',colNames,...
        'Position',[tbl_x 40 460 604],...
        'ColumnWidth',{60,68,60,60,55,55,58,70,65,65},...
        'BackgroundColor',[C.statBg; C.panel],...
        'ForegroundColor',C.text,'FontSize',9);

    % ── Bottom status bar ─────────────────────────────────────────────
    uipanel(fig4,'Position',[0 0 1180 36],'BackgroundColor',[0.06 0.08 0.10],'BorderType','none');
    status_lbl = uilabel(fig4,'Text','SYSTEM READY  |  CONFIGURE PARAMETERS AND PRESS RUN',...
        'Position',[20 8 700 20],'FontSize',9,'FontColor',C.sub);
    uipanel(fig4,'Position',[0 36 1180 1],'BackgroundColor',C.accent,'BorderType','none');

    % ── Button callbacks ──────────────────────────────────────────────
    run_btn.ButtonPushedFcn = @(~,~) runAndEnableGlobe( ...
        temp_ent.Value, fuel_ent.Value, psi_ent.Value, gamma_ent.Value, ...
        res_table, summary_label, specs, cairo_coords, target_coords, ...
        G_CONST, GM, ATM_PRESSURE, RE_M, GAS_PRESSURE, R_SPECIFIC, ...
        trajectory_distance_km, globe_btn, ...
        tile_vals, phase_lbl, mach_lbl, status_lbl, C);

    globe_btn.ButtonPushedFcn = @(~,~) window5( ...
        res_table.Data, cairo_coords, target_coords, specs);
end

% ════════════════════════════════════════════════════════════════════
%  LOOKUP KEY BUILDER
% ════════════════════════════════════════════════════════════════════
function key = buildLookupKey(specs, target_coords, manual_defaults)
    key = '';
    if isfield(target_coords, 'name')
        tgt_name = target_coords.name;
    else
        tgt_name = '';
        if isempty(tgt_name), return; end
    end
    if isfield(specs, 'name')
        rocket_name = specs.name;
    else
        rocket_name = resolveRocketName(specs);
    end
    if ~isempty(rocket_name) && ~isempty(tgt_name)
        key = [rocket_name '|' tgt_name];
    end
end

% ════════════════════════════════════════════════════════════════════
%  ROCKET NAME RESOLVER
% ════════════════════════════════════════════════════════════════════
function name = resolveRocketName(specs)
    fp = { ...
        3800,  700,   'Iskander-M';   ...
        6200,  500,   'DF-15';        ...
        3415,  500,   'KN-23';        ...
        3500,  500,   'Fateh-110';    ...
        4650,  700,   'Ghaznavi';     ...
        8000,  100,   'Shahab-3';     ...
        19000, 1200,  'Musudan';      ...
        15850, 750,   'Ghauri I/II';  ...
        23600, 1230,  'Shaheen-II';   ...
        10000, 100,   'Agni-II';      ...
        2000,  200,   'Agni-IV';      ...
        24700, 650,   'Hwasong-12';   ...
        36000, 1000,  'Hyunmoo-5';    ...
        30000, 1000,  'Shahab-5';     ...
        20000, 1000,  'Shaheen-III';  ...
        36030, 1000,  'Minuteman III';...
        49600, 1200,  'RS-24 Yars';   ...
        40000, 1500,  'Shahab-6';     ...
        36000, 800,   'RS-26 Rubezh'; ...
        72000, 1000,  'Hwasong-15/17' ...
    };
    name = '';
    for k = 1:size(fp,1)
        if specs.dry_mass == fp{k,1} && specs.warhead_mass == fp{k,2}
            name = fp{k,3};
            return;
        end
    end
end

% ════════════════════════════════════════════════════════════════════
%  RESOLVE VALUE
% ════════════════════════════════════════════════════════════════════
function v = resolveValue(manual_val, fallback_val)
    if isnan(manual_val)
        v = fallback_val;
    else
        v = manual_val;
    end
end

% ════════════════════════════════════════════════════════════════════
% Recalculate gamma when user changes fuel
% ════════════════════════════════════════════════════════════════════
function recalcGamma(gamma_ent, fuel_ent, specs, dist_km, G_CONST)
    new_gamma = computeOptimalGamma(specs, dist_km, fuel_ent.Value, G_CONST);
    gamma_ent.Value = new_gamma;
end

% ════════════════════════════════════════════════════════════════════
% Compute optimal gamma from ballistic range equation
% ════════════════════════════════════════════════════════════════════
function gamma_deg = computeOptimalGamma(specs, dist_km, fuel_kg, G_CONST)
    final_mass  = specs.dry_mass + specs.warhead_mass;
    exhaust_vel = specs.isp * G_CONST;
    dv_est      = exhaust_vel * log((final_mass + fuel_kg) / final_mass);
    v_bo        = min(dv_est, 7000);
    R_m         = dist_km * 1000;
    arg         = min(1.0, R_m * G_CONST / max(1, v_bo^2));
    gamma_deg   = rad2deg(0.5 * asin(arg));
    gamma_deg   = max(20.0, min(80.0, gamma_deg));
end

% ════════════════════════════════════════════════════════════════════
% Fuel mass lookup
% ════════════════════════════════════════════════════════════════════
function fuel = getFuelMass(dry_mass, warhead_mass)
    total_struct = dry_mass + warhead_mass;
    if     total_struct <= 4200,  fuel = 2700;
    elseif total_struct <= 4600,  fuel = 3600;
    elseif total_struct <= 5400,  fuel = 3400;
    elseif total_struct <= 7000,  fuel = 9400;
    elseif total_struct <= 17000, fuel = 29000;
    elseif total_struct <= 18700, fuel = 37000;
    elseif total_struct <= 20500, fuel = 38000;
    elseif total_struct <= 24900, fuel = 44000;
    elseif total_struct <= 25400, fuel = 39000;
    elseif total_struct <= 31000, fuel = 77000;
    elseif total_struct <= 37000, fuel = 54000;
    elseif total_struct <= 37100, fuel = 79000;
    elseif total_struct <= 45000, fuel = 45000;
    elseif total_struct <= 50900, fuel = 74000;
    elseif total_struct <= 51000, fuel = 97000;
    else,                         fuel = 148000;
    end
end

% ════════════════════════════════════════════════════════════════════
% Run wrapper — passes GM through to simulation
% ════════════════════════════════════════════════════════════════════
function runAndEnableGlobe(temp, fuel_m, psi_deg, gamma_deg, res_table, ...
    summary_lbl, specs, cairo, target, G_CONST, GM, ATM_PRESSURE, RE_M, ...
    GAS_PRESSURE, R_SPECIFIC, trajectory_distance_km, globe_btn, ...
    tile_vals, phase_lbl, mach_lbl, status_lbl, C)

    status_lbl.Text      = 'COMPUTING TRAJECTORY  |  PLEASE WAIT...';
    status_lbl.FontColor = C.accent;
    drawnow;

    runSimulation(temp, fuel_m, psi_deg, gamma_deg, res_table, summary_lbl, ...
        specs, cairo, target, G_CONST, GM, ATM_PRESSURE, RE_M, ...
        GAS_PRESSURE, R_SPECIFIC, trajectory_distance_km, ...
        tile_vals, phase_lbl, mach_lbl, C);

    globe_btn.Enable     = 'on';
    status_lbl.Text      = 'SIMULATION COMPLETE  |  GLOBE VIEW NOW AVAILABLE';
    status_lbl.FontColor = C.greenHi;
end

% ════════════════════════════════════════════════════════════════════
% Helpers
% ════════════════════════════════════════════════════════════════════
function mk_section(parent, txt, y, C)
    uipanel(parent,'Position',[10 y-4 400 1],'BackgroundColor',C.accent,'BorderType','none');
    uilabel(parent,'Text',txt,'Position',[10 y 360 20],...
        'FontSize',9,'FontWeight','bold','FontColor',C.accent);
end

function mk_ro_row(parent, lbl, val, unit, y, C)
    uilabel(parent,'Text',lbl,'Position',[10 y 160 22],'FontSize',10,'FontColor',C.sub);
    uipanel(parent,'Position',[180 y 170 22],'BackgroundColor',C.statBg,'BorderType','none');
    uilabel(parent,'Text',num2str(val),'Position',[184 y 120 22],...
        'FontSize',10,'FontWeight','bold','FontColor',C.text);
    uilabel(parent,'Text',unit,'Position',[308 y 60 22],'FontSize',9,'FontColor',C.sub,...
        'HorizontalAlignment','right');
end

function bearing = calculateBearing(lat1,lon1,lat2,lon2)
    lat1=deg2rad(lat1); lon1=deg2rad(lon1);
    lat2=deg2rad(lat2); lon2=deg2rad(lon2);
    dLon=lon2-lon1;
    y=sin(dLon)*cos(lat2);
    x=cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(dLon);
    bearing=mod(rad2deg(atan2(y,x))+360,360);
end

function Cd = dragCoefficient(mach)
    if     mach < 0.8, Cd = 0.20;
    elseif mach < 1.2, Cd = 0.50;
    else,              Cd = 0.35;
    end
end

% ════════════════════════════════════════════════════════════════════
%  ACCELERATION KERNEL  —  called at each RK4 sub-step
%
%  Computes [ax, ay] from current velocity (vx,vy), altitude h,
%  mass curr_m, and thrust.
%
%  Physics included:
%    • Altitude-dependent gravity  g(h) = GM / (RE + h)^2
%    • ISA atmosphere (density, sound speed)
%    • Mach-dependent drag
%    • Thrust resolved along velocity vector (gamma)
% ════════════════════════════════════════════════════════════════════
function [ax, ay] = computeAccel(vx, vy, h, curr_m, thrust, ...
                                  specs, GM, RE_M, ATM_PRESSURE, R_SPECIFIC)
    % Altitude-dependent gravity  g(h) = GM / (RE + h)^2
    g_h = GM / (RE_M + max(0, h))^2;

    % ISA atmosphere at altitude h
    if     h < 11000, temp_atm = 15.04  - 0.00649*h;
    elseif h < 25000, temp_atm = -56.46;
    else,             temp_atm = -131.21 + 0.00299*h;
    end
    temp_atm_K = temp_atm + 273.15;
    atm_base   = max(0, 1 - 0.0065*h/288.15);
    pa_pa      = max(0, ATM_PRESSURE*1000*(atm_base^5.2561));
    air_dens   = max(0, pa_pa/(R_SPECIFIC*temp_atm_K));
    sound_spd  = sqrt(max(1e-6, 1.4*R_SPECIFIC*temp_atm_K));

    v     = sqrt(vx^2 + vy^2);
    mach  = v / sound_spd;
    Cd    = dragCoefficient(mach);
    area  = pi*(specs.diameter/2)^2;
    drag  = 0.5*air_dens*v^2*Cd*area;

    gamma = atan2(vy, vx);          % flight path angle from velocity vector
    F_net = thrust - drag;

    ax = F_net * cos(gamma) / curr_m;
    ay = F_net * sin(gamma) / curr_m - g_h;   % altitude-dependent gravity
end

% ════════════════════════════════════════════════════════════════════
%  SIMULATION  —  RK4 integration with altitude-dependent gravity
%
%  State vector at each step:  [vx, vy, x_horiz, h_vert]
%
%  RK4 stages:
%    k1 = f( t,         S         )
%    k2 = f( t+dt/2,    S+dt/2*k1 )
%    k3 = f( t+dt/2,    S+dt/2*k2 )
%    k4 = f( t+dt,      S+dt*k3   )
%    S_new = S + (dt/6)*(k1 + 2*k2 + 2*k3 + k4)
% ════════════════════════════════════════════════════════════════════
function runSimulation(temp, fuel_m, psi_deg, gamma_input_deg, res_table, ...
    summary_lbl, specs, cairo, target, G_CONST, GM, ATM_PRESSURE, RE_M, ...
    GAS_PRESSURE, R_SPECIFIC, trajectory_distance_km, tile_vals, phase_lbl, mach_lbl, C)

    dt          = 0.1;
    final_mass  = specs.dry_mass + specs.warhead_mass;
    curr_m      = final_mass + fuel_m;
    exhaust_vel = specs.isp * G_CONST;   % G_CONST kept here per Isp convention

    gamma = deg2rad(gamma_input_deg);
    psi   = deg2rad(psi_deg);

    % Initial velocity decomposed into components
    h  = 0;
    v  = 10;
    vx = v * cos(gamma);
    vy = v * sin(gamma);

    lat_curr   = deg2rad(cairo.lat);
    lon_curr   = deg2rad(cairo.lon);
    lat_target = deg2rad(target.lat);
    lon_target = deg2rad(target.lon);
    d_done     = 0;

    results       = cell(5000,10);
    result_idx    = 1;
    last_log_time = 0;
    peak_mach     = 0;
    max_alt       = 0;
    t             = 0;

    for t = 0:dt:5000

        h = max(0, real(h));

        % ── Atmosphere at current step (for Mach tracking & thrust) ───
        if     h < 11000, temp_atm = 15.04  - 0.00649*h;
        elseif h < 25000, temp_atm = -56.46;
        else,             temp_atm = -131.21 + 0.00299*h;
        end
        temp_atm_K = temp_atm + 273.15;
        atm_base   = max(0, 1 - 0.0065*h/288.15);
        pa_pa      = max(0, real(ATM_PRESSURE*1000*(atm_base^5.2561)));
        air_dens   = max(0, real(pa_pa/(R_SPECIFIC*temp_atm_K)));
        sound_spd  = sqrt(max(1e-6, 1.4*R_SPECIFIC*temp_atm_K));
        v          = sqrt(real(vx)^2 + real(vy)^2);
        mach       = v / sound_spd;
        if mach > peak_mach, peak_mach = mach; end

        % ── Thrust (computed once per timestep; mass burns linearly) ──
        thrust = 0;
        if curr_m > final_mass
            thrust = specs.mass_flow_rate*exhaust_vel + ...
                     max(0,(GAS_PRESSURE*1000 - pa_pa))*(pi*(specs.diameter/2)^2);
            curr_m = max(final_mass, curr_m - specs.mass_flow_rate*dt);
        end

        % ════════════════════════════════════════════════════════════
        %  RK4 — four slope evaluations per timestep
        % ════════════════════════════════════════════════════════════

        % k1  —  slopes at current state
        [ax1, ay1] = computeAccel(vx, vy, h, curr_m, thrust, ...
                                   specs, GM, RE_M, ATM_PRESSURE, R_SPECIFIC);
        k1_vx = ax1;   k1_vy = ay1;
        k1_x  = vx;    k1_h  = vy;

        % k2  —  slopes at midpoint estimated with k1
        vx2 = vx + 0.5*dt*k1_vx;
        vy2 = vy + 0.5*dt*k1_vy;
        h2  = max(0, h + 0.5*dt*k1_h);
        [ax2, ay2] = computeAccel(vx2, vy2, h2, curr_m, thrust, ...
                                   specs, GM, RE_M, ATM_PRESSURE, R_SPECIFIC);
        k2_vx = ax2;   k2_vy = ay2;
        k2_x  = vx2;   k2_h  = vy2;

        % k3  —  slopes at midpoint estimated with k2
        vx3 = vx + 0.5*dt*k2_vx;
        vy3 = vy + 0.5*dt*k2_vy;
        h3  = max(0, h + 0.5*dt*k2_h);
        [ax3, ay3] = computeAccel(vx3, vy3, h3, curr_m, thrust, ...
                                   specs, GM, RE_M, ATM_PRESSURE, R_SPECIFIC);
        k3_vx = ax3;   k3_vy = ay3;
        k3_x  = vx3;   k3_h  = vy3;

        % k4  —  slopes at end of step estimated with k3
        vx4 = vx + dt*k3_vx;
        vy4 = vy + dt*k3_vy;
        h4  = max(0, h + dt*k3_h);
        [ax4, ay4] = computeAccel(vx4, vy4, h4, curr_m, thrust, ...
                                   specs, GM, RE_M, ATM_PRESSURE, R_SPECIFIC);
        k4_vx = ax4;   k4_vy = ay4;
        k4_x  = vx4;   k4_h  = vy4;

        % ── Weighted RK4 update  (1/6)(k1 + 2k2 + 2k3 + k4) ─────────
        vx_new = real(vx) + (dt/6)*(k1_vx + 2*k2_vx + 2*k3_vx + k4_vx);
        vy_new = real(vy) + (dt/6)*(k1_vy + 2*k2_vy + 2*k3_vy + k4_vy);
        dx_h   =            (dt/6)*(k1_x  + 2*k2_x  + 2*k3_x  + k4_x );
        dh     =            (dt/6)*(k1_h  + 2*k2_h  + 2*k3_h  + k4_h );

        if abs(vx_new)<1e-9 && abs(vy_new)<1e-9, vx_new=1e-9; end

        vx    = real(vx_new);
        vy    = real(vy_new);
        v     = sqrt(vx^2 + vy^2);
        gamma = atan2(vy, vx);

        h      = max(0, real(h + dh));
        d_done = d_done + abs(real(dx_h));
        if h > max_alt, max_alt = h; end

        % ── Spherical Earth lat/lon update ────────────────────────────
        d_step = abs(real(dx_h));
        if d_step > 1e-6
            sin_lat_new = sin(lat_curr)*cos(d_step/RE_M) + ...
                          cos(lat_curr)*sin(d_step/RE_M)*cos(psi);
            sin_lat_new = max(-1, min(1, real(sin_lat_new)));
            lat_new     = asin(sin_lat_new);
            lon_new     = lon_curr + atan2( ...
                              sin(psi)*sin(d_step/RE_M)*cos(lat_curr), ...
                              cos(d_step/RE_M)-sin(lat_curr)*sin(lat_new));
            lat_curr = lat_new;
            lon_curr = lon_new;
        end

        % ── Telemetry log every 10 s or on impact ─────────────────────
        if t >= last_log_time+10 || (h<=0 && t>10)
            Cd_log   = dragCoefficient(mach);
            drag_log = 0.5*air_dens*v^2*Cd_log*(pi*(specs.diameter/2)^2);

            results{result_idx,1}  = round(t,2);
            results{result_idx,2}  = round(v,2);
            results{result_idx,3}  = round(h/1000,2);
            results{result_idx,4}  = round(d_done/1000,2);
            results{result_idx,5}  = round(rad2deg(real(lat_curr)),4);
            results{result_idx,6}  = round(rad2deg(real(lon_curr)),4);
            results{result_idx,7}  = round(rad2deg(gamma),2);
            results{result_idx,8}  = round(real(thrust),2);
            results{result_idx,9}  = round(drag_log,2);
            results{result_idx,10} = round(real(curr_m),2);
            result_idx    = result_idx + 1;
            last_log_time = t;
        end

        if h<=0 && t>10, break; end
    end

    % ── Post-simulation output ────────────────────────────────────────
    results = results(1:result_idx-1,:);
    res_table.Data = results;

    dlat2    = lat_target - lat_curr;
    dlon2    = lon_target - lon_curr;
    a2       = sin(dlat2/2)^2 + cos(lat_curr)*cos(lat_target)*sin(dlon2/2)^2;
    error_km = (RE_M*2*atan2(sqrt(max(0,a2)),sqrt(max(0,1-a2))))/1000;

    if ~isempty(results)
        alt_vals  = cell2mat(results(:,3));
        vel_final = results{end,2};

        tile_vals(1).Text = sprintf('%.1f', max(alt_vals));
        tile_vals(2).Text = sprintf('%.0f', t);
        tile_vals(3).Text = sprintf('%.0f', vel_final);
        accuracy_pct = max(0, (1 - error_km / trajectory_distance_km) * 100);
        tile_vals(4).Text = sprintf('%.1f', accuracy_pct);

        if     accuracy_pct >= 97, tile_vals(4).FontColor = C.greenHi;
        elseif accuracy_pct >= 85, tile_vals(4).FontColor = C.accent;
        else,                       tile_vals(4).FontColor = C.danger;
        end

        last_angle = results{end,7};
        if last_angle < 0
            phase_lbl.Text='TERMINAL  ↘'; phase_lbl.FontColor=C.danger;
        elseif last_angle > 45
            phase_lbl.Text='ASCENT  ↑';   phase_lbl.FontColor=C.greenHi;
        else
            phase_lbl.Text='MIDCOURSE  →';phase_lbl.FontColor=C.accent;
        end

        mach_lbl.Text = sprintf('MACH  %.2f', peak_mach);

        summary_lbl.FontColor = C.text;
        summary_lbl.Text = sprintf( ...
            '■ SIMULATION COMPLETE\n  Impact Lat/Lon :  %.4f° / %.4f°\n  Accuracy :  %.1f%%\n  Target Error (CEP) :  %.2f km\n  Flight Time :  %.1f s\n  Peak Altitude :  %.1f km\n  Ground Track :  %.2f km\n  Launch Angle γ :  %.1f°', ...
            rad2deg(lat_curr), rad2deg(lon_curr), accuracy_pct, error_km, ...
            t, max(alt_vals), d_done/1000, gamma_input_deg);
    else
        summary_lbl.Text      = '✗  SIMULATION FAILED — NO VALID RESULTS';
        summary_lbl.FontColor = C.danger;
    end
end