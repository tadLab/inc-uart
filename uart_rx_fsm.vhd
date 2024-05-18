-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Tadeáš Novotný (xnovot00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity UART_RX_FSM is
    port(
        CLK         :  in std_logic;
        RST         :  in std_logic;
        DIN         :  in std_logic;
        MID_CNT     :  in std_logic_vector (4 downto 0);
        BIT_CNT     :  in std_logic_vector (3 downto 0);
        DATA_VLD    :  out std_logic;
        CNT_EN      :  out std_logic;
        RCV_EN      :  out std_logic
    );
end entity;

architecture behavioral of UART_RX_FSM is

    type state_type is (START_BIT, MID_BIT, UNTIL_END, STOP_BIT, VALID);
    signal state : state_type := START_BIT;
    
begin
    process(CLK)
    begin
    if rising_edge (CLK) then
        if RST = '1' then
            state <= START_BIT; 
        else
            case state is
                when START_BIT =>
                    if DIN = '0' then
                        state <= MID_BIT;
                        CNT_EN <= '1';
                    end if;
                    
                when MID_BIT =>
                    if MID_CNT = "11000" then
                        state <= UNTIL_END;
                        RCV_EN <= '1';
                    end if;
                    
                when UNTIL_END =>
                    if BIT_CNT = "1000" then
                        state <= STOP_BIT;
                        CNT_EN <= '0';
                    end if;
                
                when STOP_BIT =>
                    RCV_EN <= '0';
                    if DIN = '1' then
                        state <= VALID;
                        DATA_VLD <= '1'; 
                    end if;
                when VALID =>
                    state <= START_BIT;
                    DATA_VLD <= '0';  
                when others => NULL;
            end case;
        end if;
    end if;
    end process;
end architecture;
