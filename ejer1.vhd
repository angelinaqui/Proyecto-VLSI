library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity proy is
    port (
        clk, pi, pf, rst, clkU, sensor_eco : in std_logic;
        displayunidades: out std_logic_vector(6 downto 0);
        displaydecenas: out std_logic_vector(6 downto 0);
        displaycentenas: out std_logic_vector(6 downto 0);
		  centimetros_out: out unsigned(15 downto 0);
        control, sensor_disp, led_20cm, led_5cm : out std_logic
    );
end entity;

architecture Behavioral of proy is
    signal clkl: std_logic;
    signal duty : integer range 0 to 200 := 85;
	 signal centimetros_sig: std_logic_vector(15 downto 0);
    
    -- Señales intermedias para los displays
    signal displayunidades_sig: std_logic_vector(6 downto 0);
    signal displaydecenas_sig: std_logic_vector(6 downto 0);
    signal displaycentenas_sig: std_logic_vector(6 downto 0);
begin
    u1: entity work.divf(arqdivf) 
        generic map(500) 
        port map (clk => clk, clkl => clkl);
        
    u2: entity work.senal(arqsnl) 
        port map (clkl, duty, control);
        
    u3: entity work.sonicos(arqsonicos) 
        port map(
            clkU => clkU,
            sensor_disp => sensor_disp,
            sensor_eco => sensor_eco,
            led_20cm => led_20cm,
            led_5cm => led_5cm,
            displayunidades => displayunidades_sig,
            displaydecenas => displaydecenas_sig,
            displaycentenas => displaycentenas_sig,
				centimetros_out => centimetros_sig
        );
		  
	 -- Asignación de las señales intermedias a las salidas de la entidad
    displayunidades <= displayunidades_sig;
    displaydecenas <= displaydecenas_sig;
    displaycentenas <= displaycentenas_sig;
		  
	 u4: entity work.movimiento(arqmov) 
        port map(clkl, pi, pf, rst,centimetros_sig,duty);

end Behavioral;
