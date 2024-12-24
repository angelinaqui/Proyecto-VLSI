library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sonicos is
    Port (
        clkU: in STD_LOGIC;
        -- sensor
        sensor_disp: out STD_LOGIC;
        sensor_eco: in STD_LOGIC;

        -- distancia
        displayunidades: out std_logic_vector(6 downto 0);
        displaydecenas: out std_logic_vector(6 downto 0);
        displaycentenas: out std_logic_vector(6 downto 0); -- Nuevo puerto para centenas

        -- LEDs
        led_20cm: out std_logic; -- LED que se enciende a 20 cm
        led_5cm: out std_logic;   -- LED que se enciende a 5 cm
		  
		  centimetros_out: out std_logic_vector(15 downto 0)
    );
end sonicos;

architecture arqsonicos of sonicos is
    signal cuenta: unsigned(16 downto 0) := (others => '0');
    
    -- conversión de unidades
    signal centimetros: unsigned(15 downto 0) := (others => '0');
    signal centimetros_unid: unsigned(3 downto 0) := (others => '0');
    signal centimetros_dece: unsigned(3 downto 0) := (others => '0');
    signal centimetros_cent: unsigned(3 downto 0) := (others => '0'); -- Nueva señal para centenas
    signal sal_unid: unsigned(3 downto 0) := (others => '0');
    signal sal_dece: unsigned(3 downto 0) := (others => '0');
    signal sal_cent: unsigned(3 downto 0) := (others => '0'); -- Nueva señal para salida de centenas
    signal digitounidad: unsigned(3 downto 0) := (others => '0');
    signal digitodecena: unsigned(3 downto 0) := (others => '0');
    signal digitocentena: unsigned(3 downto 0) := (others => '0'); -- Nueva señal para digito de centenas

    -- señales del sensor
    signal eco_pasado: std_logic := '0';
    signal eco_sinc: std_logic := '0';
    signal eco_nsinc: std_logic := '0';

    signal espera: std_logic := '0';
    signal siete_seg_cuenta: unsigned(15 downto 0) := (others => '0');

begin

-- trabajo del sensor 
    Trigger: process(clkU)
    begin
        if rising_edge(clkU) then
            if espera = '0' then
                if cuenta = 500 then
                    sensor_disp <= '0';
                    espera <= '1';
                    cuenta <= (others => '0');
                else
                    sensor_disp <= '1';
                    cuenta <= cuenta + 1;
                end if;
            
            -- distancia
            elsif eco_pasado = '0' and eco_sinc = '1' then
                cuenta <= (others => '0');
                centimetros <= (others => '0');
                centimetros_unid <= (others => '0');
                centimetros_dece <= (others => '0');
                centimetros_cent <= (others => '0'); -- Reset de centenas

            elsif eco_pasado = '1' and eco_sinc = '0' then
                sal_unid <= centimetros_unid;
                sal_dece <= centimetros_dece;
                sal_cent <= centimetros_cent; -- Salida de centenas
                digitounidad <= sal_unid;
                digitodecena <= sal_dece;
                digitocentena <= sal_cent; -- Asignación del dígito de centenas
                
                -- Control de los LEDs
					 centimetros_out <= std_logic_vector(centimetros);
                if centimetros <= 5 then
                    led_5cm <= '1';
                    led_20cm <= '0'; -- Apagar LED de 20 cm cuando esté a 5 cm
                elsif centimetros <= 20 then
                    led_20cm <= '1';
                    led_5cm <= '0'; -- Apagar LED de 5 cm cuando esté a 20 cm
                else
                    led_5cm <= '0';
                    led_20cm <= '0'; -- Apagar ambos LEDs si está a más de 20 cm
                end if;

            elsif cuenta = 2900 - 1 then
                if centimetros_unid = 9 then
                    centimetros_unid <= (others => '0');
                    if centimetros_dece = 9 then
                        centimetros_dece <= (others => '0');
                        centimetros_cent <= centimetros_cent + 1; -- Incremento de centenas
                    else
                        centimetros_dece <= centimetros_dece + 1;
                    end if;
                else
                    centimetros_unid <= centimetros_unid + 1;
                end if;
                centimetros <= centimetros + 1;
                cuenta <= (others => '0');
                
                if centimetros = 3448 then
                    espera <= '0';
                end if;
                
            else
                cuenta <= cuenta + 1;
            end if;

            eco_pasado <= eco_sinc;
            eco_sinc <= eco_nsinc;
            eco_nsinc <= sensor_eco;
        end if;
    end process;

    -- Display unidades
    Unidades: process(digitounidad)
    begin
        case digitounidad is
            when "0000" => displayunidades <= "1000000";
            when "0001" => displayunidades <= "1111001";
            when "0010" => displayunidades <= "0100100";
            when "0011" => displayunidades <= "0110000";
            when "0100" => displayunidades <= "0011001";
            when "0101" => displayunidades <= "0010010";
            when "0110" => displayunidades <= "0000010";
            when "0111" => displayunidades <= "1111000";
            when "1000" => displayunidades <= "0000000";
            when "1001" => displayunidades <= "0011000";
            when others => displayunidades <= "1111111";
        end case;
    end process;

    -- Display decenas
    Decenas: process(digitodecena)
    begin
        case digitodecena is
            when "0000" => displaydecenas <= "1000000";
            when "0001" => displaydecenas <= "1111001";
            when "0010" => displaydecenas <= "0100100";
            when "0011" => displaydecenas <= "0110000";
            when "0100" => displaydecenas <= "0011001";
            when "0101" => displaydecenas <= "0010010";
            when "0110" => displaydecenas <= "0000010";
            when "0111" => displaydecenas <= "1111000";
            when "1000" => displaydecenas <= "0000000";
            when "1001" => displaydecenas <= "0011000";
            when others => displaydecenas <= "1111111";
        end case;
    end process;

    -- Display centenas
    Centenas: process(digitocentena)
    begin
        case digitocentena is
            when "0000" => displaycentenas <= "1000000";
            when "0001" => displaycentenas <= "1111001";
            when "0010" => displaycentenas <= "0100100";
            when "0011" => displaycentenas <= "0110000";
            when "0100" => displaycentenas <= "0011001";
            when "0101" => displaycentenas <= "0010010";
            when "0110" => displaycentenas <= "0000010";
            when "0111" => displaycentenas <= "1111000";
            when "1000" => displaycentenas <= "0000000";
            when "1001" => displaycentenas <= "0011000";
            when others => displaycentenas <= "1111111";
        end case;
    end process;

end;
