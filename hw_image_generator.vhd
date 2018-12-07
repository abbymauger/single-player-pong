--------------------------------------------------------------------------------
--
--   FileName:         hw_image_generator.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 64-bit Version 12.1 Build 177 SJ Full Version
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 05/10/2013 Scott Larson
--     Initial Public Release
--    
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY hw_image_generator IS
	GENERIC(
		pixels_y :	INTEGER := 478;    --row that first color will persist until
		pixels_x	:	INTEGER := 600);   --column that first color will persist until
	
	PORT(
		disp_ena		:	IN		STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
		row			:	IN		INTEGER;		--row pixel coordinate
		column		:	IN		INTEGER;		--column pixel coordinate
		clk			:	IN		STD_LOGIC;
		moveleft		:	IN		STD_LOGIC;
		moveright	:	IN		STD_LOGIC;
		red			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
		green			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
		blue			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS

SIGNAL Paddle1_x : INTEGER RANGE 1 to 1000 := 550;
SIGNAL Paddle1_y : INTEGER RANGE 1 to 1000 := 550;

SIGNAL ball_x : INTEGER RANGE 1 to 1000 :=50;
SIGNAL ball_y : INTEGER RANGE 1 to 1000 :=50;

SIGNAL end_moveleft : STD_LOGIC := '0';
SIGNAL end_moveright : STD_LOGIC := '0';

SIGNAL direc_up : STD_LOGIC := '0';  ---We changed this
SIGNAL direc_right : STD_LOGIC := '1';

SIGNAL clock_count : INTEGER := 0;
SIGNAL ball_anim_y :	INTEGER :=0;
SIGNAL ball_anim_x : INTEGER :=0;

BEGIN

PROCESS (moveleft, moveright)

BEGIN

	IF (rising_edge(clk)) THEN
		IF ((moveleft='0') AND (end_moveleft ='1')) THEN
			Paddle1_x <= (Paddle1_x -100);
		END IF;
		end_moveleft <= moveleft;
		
		IF ((moveright='0') AND (end_moveright ='1')) THEN
			Paddle1_x <= (Paddle1_x +100);
		END IF;
		end_moveright <= moveright;
	END IF;
END PROCESS;
		

	PROCESS(disp_ena, row, column, direc_up, direc_right)
BEGIN

		IF(clk'EVENT AND clk='1') THEN
		
		clock_count <= clock_count + 1;
		
		END IF;
		
		
		IF (clock_count > 228576 AND (clk'EVENT AND clk='1')) THEN
		
		clock_count <= 0;
		
		
		IF (direc_up = '1') THEN
		ball_anim_y <= ball_anim_y - 1; 
		ELSE --direc_up ='0'
		ball_anim_y <= ball_anim_y + 1; 
		END IF;
		
		
		IF (direc_right = '1') THEN
		ball_anim_x <= ball_anim_x + 1; 
		ELSE --direc_right ='0'
		ball_anim_x <= ball_anim_x - 1; 
		END IF;
		
	

		
		
		IF ((ball_anim_y - 7) > 475) AND (direc_right = '1') THEN 		
		direc_right <='1';
		direc_up <='1';
		END IF;
		
		IF ((ball_anim_y - 7) > 475) AND (direc_right = '0') THEN 		
		direc_right <='0';
		direc_up <='1';
		END IF;
		
		
		
		IF ((ball_anim_x) > 700) AND (direc_up = '1') THEN 		
		direc_right <='0';
		direc_up <='1';
		END IF;
		
		IF ((ball_anim_x) > 700) AND (direc_up = '0') THEN 		
		direc_right <='0';
		direc_up <='0';
		END IF;
		
		
		
		IF ((ball_anim_y - 7) < 0) AND (direc_right = '0') THEN 		
		direc_right <='0';
		direc_up <='0';
		END IF;		
	
		IF ((ball_anim_y - 7) < 0) AND (direc_right = '1') THEN 		
		direc_right <='1';
		direc_up <='0';
		END IF;
		
		
		
		IF ((ball_anim_x) <0) AND (direc_up = '0') THEN 		
		direc_right <='1';
		direc_up <='0';
		END IF;
		
		IF ((ball_anim_x) <0) AND (direc_up = '1') THEN 		
		direc_right <='1';
		direc_up <='1';
		END IF;
		
		
		END IF;
		
		
		
		IF(disp_ena = '1') THEN		--display time
		
		IF((column > (Paddle1_y - 15) AND (row > (Paddle1_x - 70))) AND (row < (Paddle1_x + 0)) AND (column < (Paddle1_y + 0))) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
		ELSIF((column > (ball_y - 7 + ball_anim_y) AND (row > (ball_x - 7 +ball_anim_x))) AND (row < (ball_x + 7 + ball_anim_x)) AND (column < (ball_y + 7 + ball_anim_y))) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
		
			ELSIF(row < pixels_y AND column < pixels_x) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
			ELSE
				red <= (OTHERS => '0');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '0');
			END IF;
		ELSE								--blanking time
			red <= (OTHERS => '0');
			green <= (OTHERS => '0');
			blue <= (OTHERS => '0');
		END IF;
	END PROCESS;
END behavior;