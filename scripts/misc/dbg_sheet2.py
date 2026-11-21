import os

os.environ["KICAD10_SYMBOL_DIR"] = r"C:\Program Files\KiCad\10.0\share\kicad\symbols"
os.environ["KICAD10_FOOTPRINT_DIR"] = r"C:\Program Files\KiCad\10.0\share\kicad\footprints"
os.environ["KICAD_SYMBOL_DIR"] = os.environ["KICAD10_SYMBOL_DIR"]
os.environ["KICAD_FOOTPRINT_DIR"] = os.environ["KICAD10_FOOTPRINT_DIR"]

from skidl import *
import skidl as skidl_pkg

set_default_tool(KICAD10)

NETLIST_PATH = r"C:\Users\akant\AppData\Local\Temp\opencode\dbg.net"
SVG_PATH = r"D:\kanre\kicad\netlists\kanre_m1_sheet2_carrier.svg"
os.makedirs(os.path.dirname(NETLIST_PATH), exist_ok=True)

# Footprints: each verified under C:\Program Files\KiCad\10.0\share\kicad\footprints
FP_R = "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P10.16mm_Horizontal"
FP_C = "Capacitor_THT:C_Disc_D5.0mm_W2.5mm_P5.00mm"
FP_CP_100U = "Capacitor_THT:CP_Radial_D8.0mm_P3.50mm"
FP_CP_10U = "Capacitor_THT:CP_Radial_D5.0mm_P2.00mm"
FP_U_OPTO = "Package_DIP:DIP-8_W7.62mm"
FP_TP = "TestPoint:TestPoint_Pad_D1.5mm"
FP_SMA = "Connector_Coaxial:SMA_Amphenol_132134_Vertical"
FP_J_LA = "Connector_PinHeader_2.54mm:PinHeader_2x05_P2.54mm_Vertical"


def fp_hdr(n):
    return "Connector_PinHeader_2.54mm:PinHeader_1x%02d_P2.54mm_Vertical" % n


# Nets (names follow Kanre_M1_Circuit_Netlist.csv and the sheet 2 brief)
NET_BATT_5V = Net("NET_BATT_5V")
NET_BOOST_IN = Net("NET_BOOST_IN")
NET_HV_RAW_18V = Net("NET_HV_RAW_18V")
NET_VDDA_3V3 = Net("NET_VDDA_3V3")
MCU_GND = Net("MCU_GND")
Star_AGND = Net("Star_AGND")
NET_I2C1_SCL = Net("NET_I2C1_SCL")
NET_I2C1_SDA = Net("NET_I2C1_SDA")
NET_SPI2_SCK = Net("NET_SPI2_SCK")
NET_SPI2_MISO = Net("NET_SPI2_MISO")
NET_SPI2_MOSI = Net("NET_SPI2_MOSI")
NET_SPI2_CS = Net("NET_SPI2_CS")
NET_RTD_RDY = Net("NET_RTD_RDY")
NET_TEMP_ALERT = Net("NET_TEMP_ALERT")
NET_DS18B20_DQ = Net("NET_DS18B20_DQ")
NET_ADC_DIFF_POS = Net("NET_ADC_DIFF_POS")
NET_ADC_DIFF_NEG = Net("NET_ADC_DIFF_NEG")
NET_DAC_SERVO = Net("NET_DAC_SERVO")
NET_RF_CLK0 = Net("NET_RF_CLK0")
NET_RF_LPF = Net("NET_RF_LPF")
NET_RF_AGG_OUT = Net("NET_RF_AGG_OUT")
NET_SPI1_SCK = Net("NET_SPI1_SCK")
NET_SPI1_MOSI = Net("NET_SPI1_MOSI")
NET_FAIL_PIN = Net("NET_FAIL_PIN")
NET_LA_SCK = Net("NET_LA_SCK")
NET_LA_MOSI = Net("NET_LA_MOSI")
LA_5V = Net("LA_5V")
ISOLATED_LA_GND = Net("ISOLATED_LA_GND")


def part(lib, name, ref, value, footprint):
    return Part(lib, name, ref=ref, value=value, footprint=footprint)


def two(p, a, b):
    p[1] += a
    p[2] += b


def socket(ref, value, pads):
    p = part("Connector_Generic", "Conn_01x19", ref, value, fp_hdr(19))
    for n in range(1, 20):
        if n in pads:
            p[n] += pads[n]
        else:
            p[n] += NC
    return p


def pin_block(ref, n, nets):
    p = part("Connector_Generic", "Conn_01x%02d" % n, ref, "%d-pin" % n, fp_hdr(n))
    for i, net in enumerate(nets, start=1):
        p[i] += net
    return p


# --- Nucleo-G491RE morpho sockets (UM2505 Table 16; pad n = pin 2n-1 for A, 2n for B) ---
# Only pads named in the brief are labelled. All other pads are NC.
# Spare pad used: J_CN10B pad12 = PB1 for DS18B20 DQ (see deviation list).
J_CN7A = socket("J_CN7A", "NUCLEO CN7 odd", {10: MCU_GND})
J_CN7B = socket("J_CN7B", "NUCLEO CN7 even", {
    4: MCU_GND, 10: MCU_GND, 11: MCU_GND,
    14: NET_ADC_DIFF_POS, 15: NET_ADC_DIFF_NEG, 16: NET_DAC_SERVO,
    17: NET_FAIL_PIN,
})
J_CN10A = socket("J_CN10A", "NUCLEO CN10 odd", {
    2: NET_I2C1_SCL, 3: NET_I2C1_SDA, 5: MCU_GND,
    6: NET_SPI1_SCK, 8: NET_SPI1_MOSI,
})
J_CN10B = socket("J_CN10B", "NUCLEO CN10 even", {
    8: NET_SPI2_CS, 10: MCU_GND, 12: NET_DS18B20_DQ,
    13: NET_SPI2_MOSI, 14: NET_SPI2_MISO, 15: NET_SPI2_SCK, 16: Star_AGND,
})

# --- Power ---
J_BATT = pin_block("J_BATT", 2, [NET_BATT_5V, MCU_GND])
J_INA219 = pin_block("J_INA219", 6, [NET_BATT_5V, NET_BOOST_IN, NET_VDDA_3V3, MCU_GND, NET_I2C1_SCL, NET_I2C1_SDA])
J_BOOST = pin_block("J_BOOST", 4, [NET_BOOST_IN, MCU_GND, NET_HV_RAW_18V, MCU_GND])
J_LDO = pin_block("J_LDO", 4, [NET_BOOST_IN, MCU_GND, NET_VDDA_3V3, MCU_GND])

C_BULK = part("Device", "C_Polarized", "C_BULK", "100uF 25V", FP_CP_100U)
two(C_BULK, NET_BOOST_IN, MCU_GND)
C_BULK_100N = part("Device", "C", "C_BULK_100N", "100nF", FP_C)
two(C_BULK_100N, NET_BOOST_IN, MCU_GND)
C_VDDA_10U = part("Device", "C_Polarized", "C_VDDA_10U", "10uF", FP_CP_10U)
two(C_VDDA_10U, NET_VDDA_3V3, MCU_GND)
C_VDDA_100N = part("Device", "C", "C_VDDA_100N", "100nF", FP_C)
two(C_VDDA_100N, NET_VDDA_3V3, MCU_GND)

# --- I2C1 pull-ups ---
R_PU1 = part("Device", "R", "R_PU1", "4.7k", FP_R)
two(R_PU1, NET_VDDA_3V3, NET_I2C1_SCL)
R_PU2 = part("Device", "R", "R_PU2", "4.7k", FP_R)
two(R_PU2, NET_VDDA_3V3, NET_I2C1_SDA)

# --- Sensors ---
J_TMP117 = pin_block("J_TMP117", 4, [NET_VDDA_3V3, MCU_GND, NET_I2C1_SCL, NET_I2C1_SDA])
J_MCP9808 = pin_block("J_MCP9808", 5, [NET_VDDA_3V3, MCU_GND, NET_I2C1_SCL, NET_I2C1_SDA, NET_TEMP_ALERT])
# RDY (pin 7) is wired to the connector only. No MCU pad is assigned; see deviation list.
J_RTD = pin_block("J_RTD", 8, [NET_VDDA_3V3, MCU_GND, NET_SPI2_SCK, NET_SPI2_MOSI, NET_SPI2_MISO, NET_SPI2_CS, NET_RTD_RDY, NC])
# Pin 1/2/3 order follows the brief. DS18B20 TO-92 datasheet order is 1=GND, 2=DQ, 3=VDD (see conflicts).
J_DS18B20 = pin_block("J_DS18B20", 3, [NET_VDDA_3V3, NET_DS18B20_DQ, MCU_GND])

# --- Analog in / DAC / AGND star ---
J_ADC = pin_block("J_ADC", 2, [NET_ADC_DIFF_POS, NET_ADC_DIFF_NEG])
J_DAC = pin_block("J_DAC", 2, [NET_DAC_SERVO, MCU_GND])
J_AGND = pin_block("J_AGND", 2, [Star_AGND, MCU_GND])  # the single AGND-to-GND tie on this sheet

# --- RF ---
J_DDS = pin_block("J_DDS", 7, [NET_VDDA_3V3, MCU_GND, NET_I2C1_SCL, NET_I2C1_SDA, NET_RF_CLK0, NC, NC])
R_LPF = part("Device", "R", "R_LPF", "10k", FP_R)
two(R_LPF, NET_RF_CLK0, NET_RF_LPF)
C_LPF = part("Device", "C", "C_LPF", "100pF", FP_C)
two(C_LPF, NET_RF_LPF, MCU_GND)
R_ATT1 = part("Device", "R", "R_ATT1", "10k", FP_R)
two(R_ATT1, NET_RF_LPF, NET_RF_AGG_OUT)
R_ATT2 = part("Device", "R", "R_ATT2", "100R", FP_R)
two(R_ATT2, NET_RF_AGG_OUT, MCU_GND)
J_SMA = part("Connector", "Conn_Coaxial", "J_SMA", "SMA", FP_SMA)
J_SMA[1] += NET_RF_AGG_OUT
J_SMA[2] += MCU_GND

# --- Isolation: two 6N137 channels ---
# 6N137 pins: 1 NC, 2 A, 3 C, 4 NC, 5 GND, 6 VO, 7 VE, 8 VCC (Vishay Rev 2.2, Doc 84732).
# Detector side (pins 5-8) is on the isolated domain: VCC and VE from LA_5V, GND from ISOLATED_LA_GND.
U_OPTO1 = part("Isolator", "6N137", "U_OPTO1", "6N137", FP_U_OPTO)
U_OPTO2 = part("Isolator", "6N137", "U_OPTO2", "6N137", FP_U_OPTO)
for u in (U_OPTO1, U_OPTO2):
    u[1] += NC
    u[4] += NC
    u[5] += ISOLATED_LA_GND
    u[7] += LA_5V
    u[8] += LA_5V

# Channel A: PA5 (SCK) -> 330R -> LED
# LED current: (3.3 - 1.4) / 330 = 5.8 mA, above the 5.0 mA minimum.
# If the logic analyzer sees slow edges, use 270 R (about 7.0 mA).
R_LED1 = part("Device", "R", "R_LED1", "330R", FP_R)
R_LED1[1] += NET_SPI1_SCK
R_LED1[2] += U_OPTO1[2]
U_OPTO1[3] += MCU_GND
R_PU3 = part("Device", "R", "R_PU3", "470R", FP_R)
two(R_PU3, LA_5V, NET_LA_SCK)
U_OPTO1[6] += NET_LA_SCK
C_OPTO1 = part("Device", "C", "C_OPTO1", "100nF", FP_C)
two(C_OPTO1, LA_5V, ISOLATED_LA_GND)

# Channel B: PA7 (MOSI) -> 330R -> LED
R_LED2 = part("Device", "R", "R_LED2", "330R", FP_R)
R_LED2[1] += NET_SPI1_MOSI
R_LED2[2] += U_OPTO2[2]
U_OPTO2[3] += MCU_GND
R_PU4 = part("Device", "R", "R_PU4", "470R", FP_R)
two(R_PU4, LA_5V, NET_LA_MOSI)
U_OPTO2[6] += NET_LA_MOSI
C_OPTO2 = part("Device", "C", "C_OPTO2", "100nF", FP_C)
two(C_OPTO2, LA_5V, ISOLATED_LA_GND)

# --- Logic analyzer connector (isolated side) ---
# Pin 9 is MCU_GND and pin 10 is ISOLATED_LA_GND, as briefed.
# The brief places NET_FAIL_PIN on pin 7 (table) but the text says pin 5. Table value used.
J_LA = part("Connector_Generic", "Conn_02x05_Odd_Even", "J_LA", "LA 2x5", FP_J_LA)
for n, net in {1: LA_5V, 2: ISOLATED_LA_GND, 3: NET_LA_SCK, 4: ISOLATED_LA_GND,
               5: NET_LA_MOSI, 6: ISOLATED_LA_GND, 7: NET_FAIL_PIN, 8: ISOLATED_LA_GND,
               9: MCU_GND, 10: ISOLATED_LA_GND}.items():
    J_LA[n] += net

# DEVIATION: PB0 fail pin goes straight across the isolation barrier to J_LA pin 7.
# Only two optocouplers are in the BOM. CSV step 24 specifies a 330 R series resistor here.
# The brief omits it, so it is not added here.
TP_FAIL = part("Connector", "TestPoint", "TP_FAIL", "FAIL", FP_TP)
TP_FAIL[1] += NET_FAIL_PIN

# --- Test points ---
for ref, net in [("TP_3V3", NET_VDDA_3V3), ("TP_HV", NET_HV_RAW_18V), ("TP_SCL", NET_I2C1_SCL),
                 ("TP_SDA", NET_I2C1_SDA), ("TP_AGND", Star_AGND)]:
    tp = part("Connector", "TestPoint", ref, ref.split("_", 1)[1], FP_TP)
    tp[1] += net

# --- ERC power flags ---
for net in (NET_BATT_5V, NET_VDDA_3V3, NET_HV_RAW_18V, MCU_GND, ISOLATED_LA_GND, LA_5V):
    flag = Part("power", "PWR_FLAG")
    flag[1] += net

def _skip_flag_footprint(part):
    # PWR_FLAG is an ERC-only symbol with no footprint by design. Other parts still raise.
    if part.name == "PWR_FLAG":
        return
    skidl_pkg.default_empty_footprint_handler(part)


ERC()
skidl_pkg.empty_footprint_handler = _skip_flag_footprint
generate_netlist(file_=NETLIST_PATH)
try:
    generate_svg(filepath="C:\\Users\\akant\\AppData\\Local\\Temp\\opencode", top_name="kanre_m1_sheet2_carrier")
except Exception as exc:
    import traceback; traceback.print_exc()

