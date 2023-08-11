`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    07:22:36 08/04/2023 
// Design Name: 
// Module Name:    Verilog2 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////


module Verilog2(
	input master_clock,
	output reg phi2,
	output last,
	inout [7:0] address,
	input [7:0] data,
	output latch,
	output reg hsync,
	output reg vsync,
	output reg red,
	output reg green,
	output reg blue,
	output reg intensity,
	output ram,
	output rom,
	output via,
	input rw,
	output oe,
	output we,
	input bank,
	output addr16
	);

reg half;
reg [17:0] video_addr;
reg [7:0] video_data;
reg hblank;
reg vblank;

reg [7:0] color;

assign address[6:0] = ((~phi2 && ~half) ? video_addr[6:0] : ((~phi2) ? video_addr[16:10] : 7'bzzzzzzz));
assign address[7] = ((~phi2 && ~half) ? video_addr[9] : ((~phi2) ? 1'b0 : 1'bz));

assign last = (phi2 && half) ? 1'b1 : 1'b0;
assign via = (phi2 && address[7:0] == 8'b00000111) ? 1'b0 : 1'b1;
assign ram = (~phi2 || (phi2 && ~(address[7] && address[6]) && via)) ? 1'b0 : 1'b1;
assign rom = ((phi2 && address[7] && address[6])) ? 1'b0 : 1'b1;
assign oe = (~phi2 || rw) ? 1'b0 : 1'b1;
assign we = (phi2 && half && ~rw) ? 1'b0 : 1'b1;

assign addr16 = (phi2 && address[7] && bank) ? 1'b1 : 1'b0;

assign latch = (~phi2 && ~half && master_clock) ? 1'b0 : 1'b1;

initial begin
	color[7:0] <= 8'b00000000;
end

always @(posedge master_clock) begin
	//if (~latch) begin
	//	latch <= 1'b1;
	//end

	if (half) begin
		if (phi2) begin
			//latch <= 1'b0;
		
			// colors
			if (hblank && vblank) begin
				if (color[7:0] == 8'b00000000) begin
					red <= video_data[3];
					green <= video_data[2];
					blue <= video_data[1];
					intensity <= video_data[0];
				end
				else begin
					if (video_data[3] && video_data[2]) begin
						red <= 1'b1;
						green <= 1'b1;
						blue <= 1'b1;
						intensity <= 1'b1;
					end
					if (~video_data[3] && ~video_data[2]) begin
						red <= 1'b0;
						green <= 1'b0;
						blue <= 1'b0;
						intensity <= 1'b0;
					end
					if (~video_data[3] && video_data[2]) begin
						red <= color[3];
						green <= color[2];
						blue <= color[1];
						intensity <= color[0];
					end
					if (video_data[3] && ~video_data[2]) begin
						red <= color[7];
						green <= color[6];
						blue <= color[5];
						intensity <= color[4];
					end
				end
			end
			else begin
				red <= 1'b0;
				green <= 1'b0;
				blue <= 1'b0;
				intensity <= 1'b0;
			end
			
			// writing to rom means changing colors and modes
			if (~rw && address[7] && address[6]) begin
				color[7:0] <= data[7:0];
			end
		end
		else begin
			video_data[7:0] <= data[7:0];
	
			// colors
			if (hblank && vblank) begin
				if (color[7:0] == 8'b00000000) begin
					red <= data[7];
					green <= data[6];
					blue <= data[5];
					intensity <= data[4];
				end
				else begin
					if (data[7] && data[6]) begin
						red <= 1'b1;
						green <= 1'b1;
						blue <= 1'b1;
						intensity <= 1'b1;
					end
					if (~data[7] && ~data[6]) begin
						red <= 1'b0;
						green <= 1'b0;
						blue <= 1'b0;
						intensity <= 1'b0;
					end
					if (~data[7] && data[6]) begin
						red <= color[3];
						green <= color[2];
						blue <= color[1];
						intensity <= color[0];
					end
					if (data[7] && ~data[6]) begin
						red <= color[7];
						green <= color[6];
						blue <= color[5];
						intensity <= color[4];
					end
				end
			end
			else begin
				red <= 1'b0;
				green <= 1'b0;
				blue <= 1'b0;
				intensity <= 1'b0;
			end
			
			// video sync signals
			if (video_addr[7:0] == 8'b10010100) begin
				hsync <= 1'b0;
			end
			
			if (video_addr[7:0] == 8'b10101100) begin
				hsync <= 1'b1;
			end
	
			if (video_addr[7:0] == 8'b11001000) begin	
				if (video_addr[17:8] == 10'b1000001010) begin
					vsync <= 1'b0;
				end
				
				if (video_addr[17:8] == 10'b1000001100) begin
					vsync <= 1'b1;
				end

				if (video_addr[17:8] == 10'b1000001101) begin
					video_addr[17:8] <= 10'b0000000000;
				end
				else begin
					video_addr[17:8] <= video_addr[17:8] + 1;
				end
				
				video_addr[7:0] <= 8'b00000000;
			end
			else begin
				video_addr[7:0] <= video_addr[7:0] + 1;
			end
		end
		
		phi2 <= ~phi2;
	end
	else begin
		if (phi2) begin
			// colors
			if (hblank && vblank) begin
				if (~(color[7:0] == 8'b00000000)) begin
					if (video_data[5] && video_data[4]) begin
						red <= 1'b1;
						green <= 1'b1;
						blue <= 1'b1;
						intensity <= 1'b1;
					end
					if (~video_data[5] && ~video_data[4]) begin
						red <= 1'b0;
						green <= 1'b0;
						blue <= 1'b0;
						intensity <= 1'b0;
					end
					if (~video_data[5] && video_data[4]) begin
						red <= color[3];
						green <= color[2];
						blue <= color[1];
						intensity <= color[0];
					end
					if (video_data[5] && ~video_data[4]) begin
						red <= color[7];
						green <= color[6];
						blue <= color[5];
						intensity <= color[4];
					end
				end
			end
			else begin
				red <= 1'b0;
				green <= 1'b0;
				blue <= 1'b0;
				intensity <= 1'b0;
			end
			
		end
		else begin
			// colors
			if (hblank && vblank) begin
				if (~(color[7:0] == 8'b00000000)) begin
					if (video_data[1] && video_data[0]) begin
						red <= 1'b1;
						green <= 1'b1;
						blue <= 1'b1;
						intensity <= 1'b1;
					end
					if (~video_data[1] && ~video_data[0]) begin
						red <= 1'b0;
						green <= 1'b0;
						blue <= 1'b0;
						intensity <= 1'b0;
					end
					if (~video_data[1] && video_data[0]) begin
						red <= color[3];
						green <= color[2];
						blue <= color[1];
						intensity <= color[0];
					end
					if (video_data[1] && ~video_data[0]) begin
						red <= color[7];
						green <= color[6];
						blue <= color[5];
						intensity <= color[4];
					end
				end
			end
			else begin
				red <= 1'b0;
				green <= 1'b0;
				blue <= 1'b0;
				intensity <= 1'b0;
			end
			
			// video blanking signals
			if (video_addr[7:0] == 8'b00000000) begin
				hblank <= 1'b1;
			end
			
			if (video_addr[7:0] == 8'b10000000) begin
				hblank <= 1'b0;
			end
			
			if (video_addr[7:0] == 8'b11001000) begin	
				if (video_addr[17:8] == 10'b0111111111) begin
					vblank <= 1'b0;
				end

				if (video_addr[17:8] == 10'b0000011111) begin
					vblank <= 1'b1;
				end
			end
		end
	end
	
	half <= ~half;
end

endmodule
