function window2(selectedCategory)
    % ── Data ─────────────────────────────────────────────────────────
    examples = containers.Map;
    examples('Short-Range Ballistic Missile (SRBM)')         = {'Iskander-M','DF-15','KN-23','Fateh-110','Ghaznavi'};
    examples('Medium-Range Ballistic Missile (MRBM)')        = {'Shahab-3','Musudan','Ghauri I/II','Shaheen-II','Agni-II'};
    examples('Intermediate-Range Ballistic Missile (IRBM)')  = {'Agni-IV','Hwasong-12','Hyunmoo-5','Shahab-5','Shaheen-III'};
    examples('Intercontinental Ballistic Missile (ICBM)')    = {'Minuteman III','RS-24 Yars','Shahab-6','RS-26 Rubezh','Hwasong-15/17'};

    rocket_specs = containers.Map;
    rocket_specs('Iskander-M')   = struct('dry_mass',3800, 'warhead_mass',700, 'isp',250,'diameter',0.92,'mass_flow_rate',100);
    rocket_specs('DF-15')        = struct('dry_mass',3900, 'warhead_mass',500, 'isp',260,'diameter',1.00,'mass_flow_rate',60);
    rocket_specs('KN-23')        = struct('dry_mass',3450, 'warhead_mass',500, 'isp',255,'diameter',0.95,'mass_flow_rate',55);
    rocket_specs('Fateh-110')    = struct('dry_mass',3200, 'warhead_mass',500, 'isp',240,'diameter',0.60,'mass_flow_rate',50);
    rocket_specs('Ghaznavi')     = struct('dry_mass',4000, 'warhead_mass',700, 'isp',245,'diameter',0.80,'mass_flow_rate',60);

    rocket_specs('Shahab-3')     = struct('dry_mass',4000,'warhead_mass',100,'isp',250,'diameter',1.25,'mass_flow_rate',800);
    rocket_specs('Musudan')      = struct('dry_mass',3700,'warhead_mass',1200,'isp',260,'diameter',1.50,'mass_flow_rate',777);
    rocket_specs('Ghauri I/II')  = struct('dry_mass',3800,'warhead_mass',750, 'isp',255,'diameter',1.35,'mass_flow_rate',651);
    rocket_specs('Shaheen-II')   = struct('dry_mass',3500,'warhead_mass',1230,'isp',260,'diameter',1.40,'mass_flow_rate',955);
    rocket_specs('Agni-II')      = struct('dry_mass',3300,'warhead_mass',100,'isp',255,'diameter',1.30,'mass_flow_rate',667);

    rocket_specs('Agni-IV')      = struct('dry_mass',2000,'warhead_mass',200,'isp',250,'diameter',1.25,'mass_flow_rate',400);
    rocket_specs('Hwasong-12')   = struct('dry_mass',1900,'warhead_mass',650, 'isp',265,'diameter',1.50,'mass_flow_rate',1196);
    rocket_specs('Hyunmoo-5')    = struct('dry_mass',2100,'warhead_mass',1000,'isp',260,'diameter',1.40,'mass_flow_rate',1779);
    rocket_specs('Shahab-5')     = struct('dry_mass',1980,'warhead_mass',1000,'isp',255,'diameter',2.00,'mass_flow_rate',1520);
    rocket_specs('Shaheen-III')  = struct('dry_mass',1990,'warhead_mass',1000,'isp',260,'diameter',1.40,'mass_flow_rate',1010);

    rocket_specs('Minuteman III')= struct('dry_mass',36030,'warhead_mass',1000,'isp',270,'diameter',1.68,'mass_flow_rate',2057);
    rocket_specs('RS-24 Yars')   = struct('dry_mass',49600,'warhead_mass',1200,'isp',275,'diameter',2.00,'mass_flow_rate',2771);
    rocket_specs('Shahab-6')     = struct('dry_mass',40000,'warhead_mass',1500,'isp',265,'diameter',1.80,'mass_flow_rate',2349);
    rocket_specs('RS-26 Rubezh') = struct('dry_mass',36000,'warhead_mass',800, 'isp',270,'diameter',1.80,'mass_flow_rate',2044);
    rocket_specs('Hwasong-15/17')= struct('dry_mass',72000,'warhead_mass',1000,'isp',275,'diameter',2.40,'mass_flow_rate',3982);

    currentRockets = examples(selectedCategory);

    % ── Colour palette ────────────────────────────────────────────────
    C.bg       = [0.08 0.10 0.13];
    C.panel    = [0.11 0.14 0.18];
    C.accent   = [0.95 0.65 0.10];
    C.text     = [0.90 0.92 0.95];
    C.sub      = [0.50 0.55 0.62];
    C.border   = [0.20 0.26 0.33];
    C.btnGo    = [0.18 0.55 0.34];
    C.statBg   = [0.09 0.12 0.16];
    C.statVal  = [0.40 0.85 0.60];

    % ── Figure ───────────────────────────────────────────────────────
    fig2 = uifigure( ...
        'Name',     'BMDS — Rocket Selection', ...
        'Position', [220 160 740 520], ...
        'Color',    C.bg, ...
        'Resize',   'on');

    % ── Top header bar ───────────────────────────────────────────────
    uipanel(fig2,'Position',[0 480 740 40],'BackgroundColor',C.accent,'BorderType','none');
    uilabel(fig2,'Text','⬡  BMDS  |  ROCKET SELECTION','Position',[20 484 400 28],...
        'FontSize',10,'FontWeight','bold','FontColor',C.bg);
    uilabel(fig2,'Text',['CATEGORY: ' upper(selectedCategory)],'Position',[200 484 530 28],...
        'FontSize',9,'FontWeight','bold','FontColor',[0.15 0.08 0.02],'HorizontalAlignment','right');

    % Left accent strip
    uipanel(fig2,'Position',[0 0 4 480],'BackgroundColor',C.accent,'BorderType','none');

    % ── Breadcrumb ───────────────────────────────────────────────────
    uilabel(fig2,'Text',['STEP 1: ' selectedCategory '  ›  STEP 2: SELECT ROCKET'],...
        'Position',[20 447 700 20],'FontSize',9,'FontColor',C.sub);

    uipanel(fig2,'Position',[20 443 700 1],'BackgroundColor',C.border,'BorderType','none');

    % ── Title ────────────────────────────────────────────────────────
    uilabel(fig2,'Text','STEP 2  —  SELECT ROCKET SYSTEM',...
        'Position',[20 408 500 28],'FontSize',15,'FontWeight','bold','FontColor',C.accent);
    uilabel(fig2,'Text','Select a rocket from the list. Specifications update dynamically.',...
        'Position',[20 388 600 18],'FontSize',10,'FontColor',C.sub);

    % ── Left: Dropdown + specs panel ─────────────────────────────────
    uilabel(fig2,'Text','AVAILABLE SYSTEMS','Position',[20 360 200 18],...
        'FontSize',9,'FontWeight','bold','FontColor',C.sub);

    dd = uidropdown(fig2, ...
        'Items',           currentRockets, ...
        'Position',        [20 328 320 30], ...
        'FontSize',        12, ...
        'FontWeight',      'bold', ...
        'BackgroundColor', C.panel, ...
        'FontColor',       C.accent);

    % ── Specs panel (right side) ──────────────────────────────────────
    uipanel(fig2,'Position',[370 60 350 360],'BackgroundColor',C.panel,...
        'BorderType','line','HighlightColor',C.border,'Title','');

    uilabel(fig2,'Text','TECHNICAL SPECIFICATIONS',...
        'Position',[380 395 320 18],'FontSize',9,'FontWeight','bold','FontColor',C.sub);

    % Stat rows — labels
    spec_labels = {'DRY MASS','WARHEAD MASS','SPECIFIC IMPULSE','DIAMETER','MASS FLOW RATE'};
    spec_units  = {'kg','kg','s','m','kg/s'};
    spec_fields = {'dry_mass','warhead_mass','isp','diameter','mass_flow_rate'};
    stat_y = [345 305 265 225 185];

    val_labels = gobjects(1,5);
    for k = 1:5
        uilabel(fig2,'Text',spec_labels{k},...
            'Position',[380 stat_y(k)+18 180 14],'FontSize',8,...
            'FontColor',C.sub,'FontWeight','bold');

        uipanel(fig2,'Position',[380 stat_y(k) 330 18],...
            'BackgroundColor',C.statBg,'BorderType','none');

        val_labels(k) = uilabel(fig2,'Text','—',...
            'Position',[385 stat_y(k) 220 18],'FontSize',11,...
            'FontWeight','bold','FontColor',C.statVal);

        uilabel(fig2,'Text',spec_units{k},...
            'Position',[610 stat_y(k) 90 18],'FontSize',9,...
            'FontColor',C.sub,'HorizontalAlignment','right');
    end

    % ── Spec description box ─────────────────────────────────────────
    desc_label = uilabel(fig2,'Text','',...
        'Position',[380 70 330 108],'FontSize',10,...
        'FontColor',C.text,'BackgroundColor',C.statBg,...
        'VerticalAlignment','top','WordWrap','on');

    % ── Left: rocket silhouette text art ─────────────────────────────
    uipanel(fig2,'Position',[20 60 330 260],'BackgroundColor',C.statBg,...
        'BorderType','line','HighlightColor',C.border);

    uilabel(fig2,'Text','ROCKET DESIGNATOR',...
        'Position',[30 305 300 16],'FontSize',9,...
        'FontColor',C.sub,'FontWeight','bold');

    rocket_name_lbl = uilabel(fig2,'Text',currentRockets{1},...
        'Position',[30 268 300 32],'FontSize',20,...
        'FontWeight','bold','FontColor',C.text);

    uilabel(fig2,'Text','LAUNCH AUTHORITY AUTHORIZED',...
        'Position',[30 245 300 18],'FontSize',8,...
        'FontColor',C.accent,'FontWeight','bold');

    uipanel(fig2,'Position',[30 238 300 1],'BackgroundColor',C.border,'BorderType','none');

    origin_lbl = uilabel(fig2,'Text','ORIGIN: —',...
        'Position',[30 215 300 18],'FontSize',10,'FontColor',C.sub);
    class_lbl  = uilabel(fig2,'Text','CLASS: —',...
        'Position',[30 193 300 18],'FontSize',10,'FontColor',C.sub);
    prop_lbl   = uilabel(fig2,'Text','PROPELLANT: SOLID / LIQUID',...
        'Position',[30 171 300 18],'FontSize',10,'FontColor',C.sub);

    % Initial population
    updateSpecs(dd.Value);

    % On change → update
    dd.ValueChangedFcn = @(~,~) updateSpecs(dd.Value);

    % ── Progress ─────────────────────────────────────────────────────
    uilabel(fig2,'Text','✓ STEP 1  ●  STEP 2 of 3  ○ STEP 3',...
        'Position',[20 32 300 18],'FontSize',9,'FontColor',C.accent);

    % ── Buttons ──────────────────────────────────────────────────────
    uibutton(fig2,'Text','‹ BACK','Position',[20 8 100 28],...
        'FontSize',10,'BackgroundColor',C.statBg,'FontColor',C.sub,...
        'ButtonPushedFcn',@(~,~) delete(fig2));

    btn = uibutton(fig2,'Text','PROCEED TO TARGET SELECTION  ›',...
        'Position',[460 8 260 32],'FontSize',11,'FontWeight','bold',...
        'BackgroundColor',C.btnGo,'FontColor','white');
    btn.ButtonPushedFcn = @(~,~) window3(selectedCategory, dd.Value, rocket_specs(dd.Value));

    % ── Status bar ───────────────────────────────────────────────────
    uipanel(fig2,'Position',[0 0 740 8],'BackgroundColor',C.accent,'BorderType','none');

    % ── Nested update function ────────────────────────────────────────
    function updateSpecs(rname)
        if ~isKey(rocket_specs, rname), return; end
        s = rocket_specs(rname);
        vals = {s.dry_mass, s.warhead_mass, s.isp, s.diameter, s.mass_flow_rate};
        for i = 1:5
            val_labels(i).Text = num2str(vals{i});
        end
        rocket_name_lbl.Text = rname;

        % Simple origin heuristic
        if contains(rname,{'DF','KN','Hwasong','Hyunmoo'})
            org = 'East Asia'; cls = 'Ballistic / Road-mobile';
        elseif contains(rname,{'Shahab','Shaheen','Fateh','Ghauri','Ghaznavi'})
            org = 'South-West Asia'; cls = 'Ballistic / Road-mobile';
        elseif contains(rname,{'Agni'})
            org = 'South Asia'; cls = 'Ballistic / Rail/Road-mobile';
        elseif contains(rname,{'RS','Yars','Rubezh'})
            org = 'Russia'; cls = 'Ballistic / Silo / Mobile';
        elseif contains(rname,{'Minuteman'})
            org = 'United States'; cls = 'Ballistic / Silo-based';
        elseif contains(rname,{'Iskander','Musudan'})
            org = 'Russia / DPRK'; cls = 'Ballistic / Road-mobile';
        else
            org = 'Unknown'; cls = 'Ballistic';
        end
        origin_lbl.Text = ['ORIGIN: ' org];
        class_lbl.Text  = ['CLASS: '  cls];

        total_mass = s.dry_mass + s.warhead_mass;
        mass_ratio = (total_mass + 2000) / total_mass;
        delta_v_est = s.isp * 9.81 * log(mass_ratio);
        desc_label.Text = sprintf( ...
            'Est. ΔV: %.0f m/s  |  T/W ≈ %.2f\nTotal dry+warhead: %.0f kg\nDiameter: %.2f m\nMass flow: %.0f kg/s', ...
            delta_v_est, (s.mass_flow_rate*s.isp*9.81)/(total_mass*9.81), ...
            total_mass, s.diameter, s.mass_flow_rate);
    end
end