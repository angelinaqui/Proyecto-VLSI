library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity movimiento is 
    port(
        clk, pi, pf, rst: in std_logic;
        centimetros_in: in std_logic_vector(15 downto 0); -- New input for the distance from 'sonicos'
        ancho: out integer
    );
end entity;

architecture arqmov of movimiento is
    signal valor: integer range 0 to 200 := 75;
    signal counter: integer range 0 to 50000 := 0;  -- Contador para generar el retardo
    signal enable: std_logic := '0';  -- Señal de habilitación para controlar el incremento/decremento
    signal direccion: std_logic := '1'; -- Señal para controlar la dirección: '1' para incrementar, '0' para decrementar
    signal counter_multiplier: integer := 0; -- Multiplier for the counter
begin
    process (clk, rst)
	 variable distancia: integer;
	 
    begin
        if rst = '1' then
            valor <= 75;
            counter <= 0;
            enable <= '0';
            direccion <= '1'; -- Inicialmente configurado para incrementar
				counter_multiplier <= 500;
        elsif rising_edge(clk) then
            distancia := to_integer(unsigned(centimetros_in));
				-- Convert and use a temporary variable for the calculation
			  distancia := to_integer(unsigned(centimetros_in));
			  
			  -- Calculate the counter_multiplier based on temp_distancia
			  if distancia < 100 then
					distancia := 100 - distancia;
					counter_multiplier <= distancia * 50;
			 else
					counter_multiplier <= 500;
			  end if;
            
            -- Control the increment/decrement
            if counter = counter_multiplier then  -- Use counter_multiplier here
                enable <= '1';
                counter <= 0;
            else
                counter <= counter + 1;
                enable <= '0';
            end if;

            if enable = '1' then
                if pi = '1' then
                    valor <= 55;  -- 5.5% -~1 ms
                    direccion <= '1'; -- Cambia dirección a incrementar
                elsif pf = '1' then 
                    valor <= 95;  -- 9.5% -~2ms
                    direccion <= '0'; -- Cambia dirección a decrementar
                elsif direccion = '1' and valor < 95 then
                    valor <= valor + 1;
                    if valor = 94 then
                        direccion <= '0'; -- Cambia dirección a decrementar
                    end if;
                elsif direccion = '0' and valor > 55 then
                    valor <= valor - 1;
                    if valor = 56 then
                        direccion <= '1'; -- Cambia dirección a incrementar
                    end if;
                end if;
            end if;
        end if;
    end process;

    ancho <= valor; -- Asignación continua de `ancho` al valor calculado
end architecture;
