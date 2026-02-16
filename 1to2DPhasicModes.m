%% 3D Ring Theory Animation - Phasic Helices + Radial Disc Printing
clear; clc; close all;

video_filename = 'ring_theory_disc_medium.mp4';
v = VideoWriter(video_filename, 'MPEG-4');
v.FrameRate = 50; v.Quality = 95;
open(v);

%% Parameters
total_time = 8; dt = 0.02; t = 0:dt:total_time;
radius = 1; ring_height = 2.5; flow_speed = 2.0;
max_history_time = 1.5; disc_alpha = 0.2; % Opacity for the "fainter" disc

% Speeds
continuous_speed = 2*pi/0.5;
disc_active_time = 0.4; disc_gap_time = 0.1;
comp_active_time = 0.25; comp_cycle_time = 0.5;
interrupt_cycle_time = 0.5; interrupt_print_duration = 0.02;

figure('Position', [50, 50, 2000, 600], 'Color', 'white');

% Histories
history_cont = []; history_disc = []; history_comp = [];
printed_interrupt = []; % Stores [time, type(0 for ring, 1 for disc)]

for i = 1:length(t)
    clf;
    theta_ring = linspace(0, 2*pi, 100);
    x_head = radius * cos(theta_ring); y_head = radius * sin(theta_ring); z_head = ring_height * ones(size(x_head));

    %% 1. Continuous (Point Tracer Plus Fainter Radial Arm)
    subplot(1,4,1); hold on;
    plot3(x_head, y_head, z_head, 'b-', 'LineWidth', 2);
    angle_cont = mod(t(i) * continuous_speed, 2*pi);
    x_tr = radius * cos(angle_cont); y_tr = radius * sin(angle_cont);
    history_cont = [history_cont; [x_tr, y_tr, ring_height, t(i), angle_cont]];
    history_cont = history_cont(history_cont(:,4) > t(i) - max_history_time, :);
    
    if size(history_cont, 1) > 2
        h_z = ring_height - (t(i) - history_cont(:,4)) * flow_speed;
        % Draw Radial Ribbon (The Disc Paint)
        for k = 2:length(h_z)
            if h_z(k) > -1.5
                patch([0 0 history_cont(k,1) history_cont(k-1,1)], ...
                      [0 0 history_cont(k,2) history_cont(k-1,2)], ...
                      [h_z(k) h_z(k-1) h_z(k-1) h_z(k)], 'b', 'EdgeColor', 'none', 'FaceAlpha', disc_alpha);
            end
        end
        % Draw Helix Ring
        plot3(history_cont(:,1), history_cont(:,2), h_z, 'b-', 'LineWidth', 2);
    end
    plot3([0, x_tr], [0, y_tr], [ring_height, ring_height], 'y-', 'LineWidth', 3);
    title('Continuous'); view(45,30); axis equal; grid on; zlim([-2 3.5]); xlim([-1.5 1.5]); ylim([-1.5 1.5]);

    %% 2. Discontinuous
    subplot(1,4,2); hold on;
    plot3(x_head, y_head, z_head, 'r-', 'LineWidth', 2);
    c_disc = mod(t(i), disc_active_time + disc_gap_time);
    if c_disc < disc_active_time
        a_disc = 2*pi * (c_disc / disc_active_time);
        x_tr = radius * cos(a_disc); y_tr = radius * sin(a_disc);
        history_disc = [history_disc; [x_tr, y_tr, ring_height, t(i), a_disc]];
        plot3([0, x_tr], [0, y_tr], [ring_height, ring_height], 'y-', 'LineWidth', 3);
    end
    history_disc = history_disc(history_disc(:,4) > t(i) - max_history_time, :);
    if size(history_disc, 1) > 2
        h_z = ring_height - (t(i) - history_disc(:,4)) * flow_speed;
        for k = 2:length(h_z)
            if h_z(k) > -1.5 && abs(history_disc(k,5)-history_disc(k-1,5)) < pi
                patch([0 0 history_disc(k,1) history_disc(k-1,1)], ...
                      [0 0 history_disc(k,2) history_disc(k-1,2)], ...
                      [h_z(k) h_z(k-1) h_z(k-1) h_z(k)], 'r', 'EdgeColor', 'none', 'FaceAlpha', disc_alpha);
                plot3(history_disc(k-1:k,1), history_disc(k-1:k,2), h_z(k-1:k), 'r-', 'LineWidth', 2);
            end
        end
    end
    title('Discontinuous'); view(45,30); axis equal; grid on; zlim([-2 3.5]); xlim([-1.5 1.5]); ylim([-1.5 1.5]);

    %% 3. Compressed
    subplot(1,4,3); hold on;
    plot3(x_head, y_head, z_head, 'g-', 'LineWidth', 2);
    c_comp = mod(t(i), comp_cycle_time);
    if c_comp < comp_active_time
        a_comp = 2*pi * (c_comp / comp_active_time);
        x_tr = radius * cos(a_comp); y_tr = radius * sin(a_comp);
        history_comp = [history_comp; [x_tr, y_tr, ring_height, t(i), a_comp]];
        plot3([0, x_tr], [0, y_tr], [ring_height, ring_height], 'y-', 'LineWidth', 3);
    end
    history_comp = history_comp(history_comp(:,4) > t(i) - max_history_time, :);
    if size(history_comp, 1) > 2
        h_z = ring_height - (t(i) - history_comp(:,4)) * flow_speed;
        for k = 2:length(h_z)
            if h_z(k) > -1.5 && abs(history_comp(k,5)-history_comp(k-1,5)) < pi
                patch([0 0 history_comp(k,1) history_comp(k-1,1)], ...
                      [0 0 history_comp(k,2) history_comp(k-1,2)], ...
                      [h_z(k) h_z(k-1) h_z(k-1) h_z(k)], 'g', 'EdgeColor', 'none', 'FaceAlpha', disc_alpha);
                plot3(history_comp(k-1:k,1), history_comp(k-1:k,2), h_z(k-1:k), 'g-', 'LineWidth', 2);
            end
        end
    end
    title('Compressed'); view(45,30); axis equal; grid on; zlim([-2 3.5]); xlim([-1.5 1.5]); ylim([-1.5 1.5]);

    %% 4. Interrupt (Ring Plus Fainter Disc)
    subplot(1,4,4); hold on;
    plot3(x_head, y_head, z_head, 'm-', 'LineWidth', 2);
    c_int = mod(t(i), interrupt_cycle_time);
    if c_int < interrupt_print_duration
        % The "Clasp": Ring + Disc printed at once
        fill3(x_head, y_head, z_head, 'm', 'FaceAlpha', disc_alpha, 'EdgeColor', 'none');
        plot3(x_head, y_head, z_head, 'm-', 'LineWidth', 3);
        if c_int < dt/2, printed_interrupt = [printed_interrupt; t(i)]; end
    end
    
    new_print = [];
    for j = 1:length(printed_interrupt)
        age = t(i) - printed_interrupt(j);
        if age < max_history_time
            z_pos = ring_height - age * flow_speed;
            opacity = 1 - (age / max_history_time);
            % Fading Disc
            fill3(x_head, y_head, z_pos*ones(size(x_head)), 'm', 'FaceAlpha', disc_alpha*opacity, 'EdgeColor', 'none');
            % Fading Ring
            plot3(x_head, y_head, z_pos*ones(size(x_head)), 'm-', 'LineWidth', 2, 'Color', [1 0 1]*opacity);
            new_print = [new_print; printed_interrupt(j)];
        end
    end
    printed_interrupt = new_print;
    title('Interrupt (Ring Plus Fainter Disc)'); view(45,30); axis equal; grid on; zlim([-2 3.5]); xlim([-1.5 1.5]); ylim([-1.5 1.5]);

    sgtitle('Three Phasic and One Interrupt Mode: 1D-2D');
    writeVideo(v, getframe(gcf));
end
close(v); fprintf('Video saved.\n');
