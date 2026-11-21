import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import qn, nsdecls
import os

doc = docx.Document()

# Page Setup: A4 Portrait with compact margins
section = doc.sections[0]
section.page_width = Inches(8.27)
section.page_height = Inches(11.69)
section.top_margin = Inches(0.38)
section.bottom_margin = Inches(0.35)
section.left_margin = Inches(0.52)
section.right_margin = Inches(0.52)

# Set base Normal style font
style_normal = doc.styles['Normal']
style_normal.font.name = 'Arial'
style_normal.font.size = Pt(8.9)
style_normal.font.color.rgb = RGBColor(0x11, 0x11, 0x11)

def add_border_bottom(p, color="D0D0D0", sz="6", space="2"):
    pPr = p._p.get_or_add_pPr()
    pBdr = parse_xml(f'<w:pBdr {nsdecls("w")}><w:bottom w:val="single" w:sz="{sz}" w:space="{space}" w:color="{color}"/></w:pBdr>')
    pPr.append(pBdr)

def add_hyperlink(p, url, text, font_size=Pt(8.9), color="000000", underline=False, bold=False):
    part = p.part
    r_id = part.relate_to(url, docx.opc.constants.RELATIONSHIP_TYPE.HYPERLINK, is_external=True)
    hyperlink = parse_xml(f'<w:hyperlink {nsdecls("w", "r")} r:id="{r_id}"/>')
    r = parse_xml(f'<w:r {nsdecls("w")}><w:rPr/><w:t>{text}</w:t></w:r>')
    rPr = r.find(qn('w:rPr'))
    
    # font name
    rFonts = parse_xml(f'<w:rFonts {nsdecls("w")} w:ascii="Arial" w:hAnsi="Arial"/>')
    rPr.append(rFonts)
    
    if color:
        c = parse_xml(f'<w:color {nsdecls("w")} w:val="{color}"/>')
        rPr.append(c)
    if underline:
        u = parse_xml(f'<w:u {nsdecls("w")} w:val="single"/>')
        rPr.append(u)
    if bold:
        b = parse_xml(f'<w:b {nsdecls("w")}/>')
        rPr.append(b)
    if font_size:
        sz = parse_xml(f'<w:sz {nsdecls("w")} w:val="{int(font_size.pt * 2)}"/>')
        rPr.append(sz)
        
    hyperlink.append(r)
    p._p.append(hyperlink)

def add_heading(text, space_before=Pt(6), space_after=Pt(3)):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    p.paragraph_format.space_before = space_before
    p.paragraph_format.space_after = space_after
    p.paragraph_format.line_spacing = 1.0
    run = p.add_run(text)
    run.font.name = 'Arial'
    run.font.size = Pt(10)
    run.font.bold = True
    run.font.color.rgb = RGBColor(0, 0, 0)
    add_border_bottom(p, color="D0D0D0", sz="6", space="3")
    return p

# --- HEADER ---
p_name = doc.add_paragraph()
p_name.alignment = WD_ALIGN_PARAGRAPH.CENTER
p_name.paragraph_format.space_before = Pt(0)
p_name.paragraph_format.space_after = Pt(2)
p_name.paragraph_format.line_spacing = 1.0
run_name = p_name.add_run("Antarip Kar")
run_name.font.name = 'Arial'
run_name.font.size = Pt(20.5)
run_name.font.bold = True
run_name.font.color.rgb = RGBColor(0, 0, 0)

p_head = doc.add_paragraph()
p_head.alignment = WD_ALIGN_PARAGRAPH.CENTER
p_head.paragraph_format.space_before = Pt(0)
p_head.paragraph_format.space_after = Pt(2)
p_head.paragraph_format.line_spacing = 1.0
run_head = p_head.add_run("Embedded Systems Engineer · Edge AI Researcher · IoT Developer · Bare-Metal C/C++")
run_head.font.name = 'Arial'
run_head.font.size = Pt(8.9)
run_head.font.bold = True
run_head.font.color.rgb = RGBColor(0x11, 0x11, 0x11)

p_contact = doc.add_paragraph()
p_contact.alignment = WD_ALIGN_PARAGRAPH.CENTER
p_contact.paragraph_format.space_before = Pt(0)
p_contact.paragraph_format.space_after = Pt(5)
p_contact.paragraph_format.line_spacing = 1.0

def add_contact_part(p, text, url=None):
    if url:
        add_hyperlink(p, url, text, font_size=Pt(7.7), color="222222", underline=False)
    else:
        r = p.add_run(text)
        r.font.name = 'Arial'
        r.font.size = Pt(7.7)
        r.font.color.rgb = RGBColor(0x22, 0x22, 0x22)

add_contact_part(p_contact, "+91 9479976753")
add_contact_part(p_contact, " · ")
add_contact_part(p_contact, "akantarip30@gmail.com", "mailto:akantarip30@gmail.com")
add_contact_part(p_contact, " · ")
add_contact_part(p_contact, "github.com/beastbroak30", "https://github.com/beastbroak30")
add_contact_part(p_contact, " · ")
add_contact_part(p_contact, "linkedin.com/in/beastbroak30", "https://linkedin.com/in/beastbroak30")
add_contact_part(p_contact, " · ")
add_contact_part(p_contact, "bio.link/beastbroak30", "https://bio.link/beastbroak30")
add_contact_part(p_contact, " · ")
add_contact_part(p_contact, "Indore, India")

# --- SUMMARY ---
add_heading("SUMMARY")
p_sum = doc.add_paragraph()
p_sum.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
p_sum.paragraph_format.space_before = Pt(0)
p_sum.paragraph_format.space_after = Pt(4)
p_sum.paragraph_format.line_spacing = 1.15

r = p_sum.add_run("Embedded systems developer and founder of KANRE with 3+ years of experience building IoT devices, edge-AI pipelines, specialized hardware, and low-level firmware. Emergent Ventures grant-backed founder developing an accessible TRNG system; published Arduino library author, official MicroPython contributor (")
r.font.name = 'Arial'
r.font.size = Pt(8.8)
add_hyperlink(p_sum, "https://github.com/micropython/micropython/pull/19188", "PR #19188", font_size=Pt(8.8), color="000000", underline=True)
r2 = p_sum.add_run("), and researcher in privacy-preserving human presence estimation.")
r2.font.name = 'Arial'
r2.font.size = Pt(8.8)

# --- EXPERIENCE ---
add_heading("EXPERIENCE")

def add_exp_item(role, org_and_meta, bullets):
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(1)
    p.paragraph_format.space_after = Pt(1)
    p.paragraph_format.line_spacing = 1.15
    r_role = p.add_run(role)
    r_role.font.name = 'Arial'
    r_role.font.size = Pt(9)
    r_role.font.bold = True
    r_role.font.color.rgb = RGBColor(0, 0, 0)
    
    r_rest = p.add_run(" · " + org_and_meta)
    r_rest.font.name = 'Arial'
    r_rest.font.size = Pt(9)
    r_rest.font.color.rgb = RGBColor(0x22, 0x22, 0x22)
    
    for i, b in enumerate(bullets):
        bp = doc.add_paragraph(style='List Bullet')
        bp.paragraph_format.space_before = Pt(0)
        bp.paragraph_format.space_after = Pt(3 if i == len(bullets)-1 else 1)
        bp.paragraph_format.line_spacing = 1.15
        bp.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        br = bp.add_run(b)
        br.font.name = 'Arial'
        br.font.size = Pt(8.7)
        br.font.color.rgb = RGBColor(0x11, 0x11, 0x11)

add_exp_item(
    "Founder",
    "KANRE (Emergent Ventures Grant-backed) · Self-employed · On-site · Jun 2026 – Present",
    [
        "Building physical products for spaces, edge AI, and hardware entropy.",
        "Secured a $2,800 Emergent Ventures grant through the Mercatus Center at George Mason University to develop an accessible TRNG system."
    ]
)

add_exp_item(
    "Embedded System Intern",
    "Guardex.ai · Remote · Nov 2025 – Present",
    [
        "Developing edge-optimized vision-AI models and deploying C++/Python real-time inference pipelines on single-board computers."
    ]
)

add_exp_item(
    "Embedded System Developer",
    "Freelance · Remote · Apr 2024 – Dec 2025",
    [
        "Delivered a Raspberry Pi industrial tracking system with computer vision, 4G LTE, GPS, 8MP camera, GUI, and power management under an $800 USD contract."
    ]
)

add_exp_item(
    "Embedded Project Intern",
    "Hexaed Line · Kerala (Remote) · Jun – Oct 2025",
    [
        "Built ESP32/Raspberry Pi firmware in C/C++ and MicroPython and designed custom drone PCBs."
    ]
)

add_exp_item(
    "Machine Learning Intern",
    "CODEVEDA Private Limited · India · May – Jun 2025",
    [
        "Completed an advanced Level 3 internship focused on machine-learning algorithms and project planning."
    ]
)

# --- SELECTED PROJECTS ---
add_heading("SELECTED PROJECTS")

def add_project_item(title, stack, link_text, link_url, desc):
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(1)
    p.paragraph_format.space_after = Pt(1)
    p.paragraph_format.line_spacing = 1.15
    rt = p.add_run(title)
    rt.font.name = 'Arial'
    rt.font.size = Pt(8.9)
    rt.font.bold = True
    rt.font.color.rgb = RGBColor(0, 0, 0)
    
    rs = p.add_run(" " + stack)
    rs.font.name = 'Arial'
    rs.font.size = Pt(8.3)
    rs.font.color.rgb = RGBColor(0x22, 0x22, 0x22)
    
    pl = doc.add_paragraph()
    pl.paragraph_format.space_before = Pt(0)
    pl.paragraph_format.space_after = Pt(1)
    pl.paragraph_format.line_spacing = 1.0
    add_hyperlink(pl, link_url, link_text, font_size=Pt(7.7), color="333333", underline=False)
    
    pd = doc.add_paragraph()
    pd.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
    pd.paragraph_format.space_before = Pt(0)
    pd.paragraph_format.space_after = Pt(3.5)
    pd.paragraph_format.line_spacing = 1.15
    rd = pd.add_run(desc)
    rd.font.name = 'Arial'
    rd.font.size = Pt(8.7)
    rd.font.color.rgb = RGBColor(0x11, 0x11, 0x11)

add_project_item(
    "Human Presence Estimation via RSSI",
    "[ESP32 · Python · Random Forest]",
    "github.com/beastbroak30/Human-Presence-Estimation-using-RSSI-Wi-Fi",
    "https://github.com/beastbroak30/Human-Presence-Estimation-using-RSSI-Wi-Fi",
    "Built a four-node RSSI fingerprinting system achieving 94% accuracy at approximately $50 cost. Camera supervision is used only during training; inference operates solely on RSSI. Research Square preprint, May 2026; journal manuscript under peer review."
)

add_project_item(
    "ESP32-CAM OTA Firmware Pipeline",
    "[ESP32 · C++ · GitHub Actions · Raspberry Pi Zero 2W]",
    "github.com/beastbroak30/Expressif_cam_wroom32",
    "https://github.com/beastbroak30/Expressif_cam_wroom32",
    "Built automated OTA CI/CD with versioned releases, credential injection, release artifacts, and self-hosted Raspberry Pi deployment; added QVGA video, JPEG-to-SD capture, dual-core task pinning, and PSRAM-aware buffering."
)

add_project_item(
    "FlappyCard v1.0",
    "[ATtiny85 · KiCad · C · NFC · PCB]",
    "github.com/beastbroak30",
    "https://github.com/beastbroak30",
    "Designed a credit-card Flappy Bird PCB with 8×8 LED matrix, NFC, USB-C, QR-coded profile, and approximately 28-day battery life after a two-hour charge."
)

add_project_item(
    "Mecanum ESP-NOW Robot + mecmotor",
    "[ESP32 · C++ · ESP-NOW · Arduino Library]",
    "github.com/beastbroak30/ESP-NOW_mecanum-carRC",
    "https://github.com/beastbroak30/ESP-NOW_mecanum-carRC",
    "Built an omnidirectional robot and published mecmotor v1.2.0 to the global Arduino Library Manager; won IIT Bombay Meshmerize 2025."
)

# --- TECHNICAL SKILLS ---
add_heading("TECHNICAL SKILLS")

def add_skill_line(label, items):
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(0)
    p.paragraph_format.space_after = Pt(1.5)
    p.paragraph_format.line_spacing = 1.15
    rl = p.add_run(label + " ")
    rl.font.name = 'Arial'
    rl.font.size = Pt(8.7)
    rl.font.bold = True
    rl.font.color.rgb = RGBColor(0, 0, 0)
    
    ri = p.add_run(items)
    ri.font.name = 'Arial'
    ri.font.size = Pt(8.7)
    ri.font.color.rgb = RGBColor(0x11, 0x11, 0x11)

add_skill_line("Languages:", "C, C++, Python, MicroPython")
add_skill_line("Hardware:", "ESP32, Raspberry Pi, ATtiny85, Arduino, STM32, bare-metal, RTOS, I2C, SPI, UART, PWM")
add_skill_line("AI / ML:", "TensorFlow, Keras, PyTorch, Edge Impulse, TFLite, Random Forest, CNN, computer vision")
add_skill_line("Tools / Protocols:", "KiCad, EasyEDA (JLCPCB Certified), PlatformIO, Arduino IDE, GitHub Actions, Flask, Tauri, ESP-NOW, Wi-Fi, 4G LTE, GPS/GNSS, NFC, Bluetooth")

# --- RECOGNITION & EDUCATION ---
add_heading("RECOGNITION & EDUCATION")

def add_recog_bullet(prefix_bold, rest_text, pr_link=False):
    bp = doc.add_paragraph(style='List Bullet')
    bp.paragraph_format.space_before = Pt(0)
    bp.paragraph_format.space_after = Pt(2)
    bp.paragraph_format.line_spacing = 1.15
    br_bold = bp.add_run(prefix_bold)
    br_bold.font.name = 'Arial'
    br_bold.font.size = Pt(8.5)
    br_bold.font.bold = True
    br_bold.font.color.rgb = RGBColor(0, 0, 0)
    
    if pr_link:
        br_mid = bp.add_run(" Merged upstream core security contribution in ")
        br_mid.font.name = 'Arial'
        br_mid.font.size = Pt(8.5)
        add_hyperlink(bp, "https://github.com/micropython/micropython/pull/19188", "PR #19188", font_size=Pt(8.5), color="000000", underline=True)
        br_end = bp.add_run(" (extmod/modwebrepl).")
        br_end.font.name = 'Arial'
        br_end.font.size = Pt(8.5)
    else:
        br_rest = bp.add_run(rest_text)
        br_rest.font.name = 'Arial'
        br_rest.font.size = Pt(8.5)
        br_rest.font.color.rgb = RGBColor(0x11, 0x11, 0x11)

add_recog_bullet("Official MicroPython Contributor:", "", pr_link=True)
add_recog_bullet("1st Place — IIT Bombay Meshmerize Zonal,", " Oct 2025: only school team among 38 college teams in Madhya Pradesh.")
add_recog_bullet("Emergent Ventures Grant Recipient,", " 2026: $2,800 grant through the Mercatus Center for an accessible TRNG system.")
add_recog_bullet("Natsuyasumi Project ’26,", " Tokyo: JPY 348,000 international research scholarship; Research Square preprint published May 2026.")
add_recog_bullet("Open Source & Certifications:", " published mecmotor v1.2.0 on Arduino Library Manager; JLCPCB EasyEDA Professional Certification; Claude Code in Actions (Anthropic).")

p_school = doc.add_paragraph()
p_school.paragraph_format.space_before = Pt(2)
p_school.paragraph_format.space_after = Pt(5)
p_school.paragraph_format.line_spacing = 1.15
rs_bold = p_school.add_run("St. Norbert Senior Secondary School")
rs_bold.font.name = 'Arial'
rs_bold.font.size = Pt(8.5)
rs_bold.font.bold = True
rs_bold.font.color.rgb = RGBColor(0, 0, 0)

rs_rest = p_school.add_run(", Indore · PCM / CBSE · Expected 2027 · 90%+ maintained · Founder, Robotics Club · Inaugural Innovation Cell Head (2026)")
rs_rest.font.name = 'Arial'
rs_rest.font.size = Pt(8.5)
rs_rest.font.color.rgb = RGBColor(0x11, 0x11, 0x11)

# --- FOOTER ---
p_ftr = doc.add_paragraph()
p_ftr.alignment = WD_ALIGN_PARAGRAPH.CENTER
p_ftr.paragraph_format.space_before = Pt(5)
p_ftr.paragraph_format.space_after = Pt(0)
p_ftr.paragraph_format.line_spacing = 1.0

add_contact_part(p_ftr, "github.com/beastbroak30", "https://github.com/beastbroak30")
add_contact_part(p_ftr, " · ")
add_contact_part(p_ftr, "linkedin.com/in/beastbroak30", "https://linkedin.com/in/beastbroak30")
add_contact_part(p_ftr, " · ")
add_contact_part(p_ftr, "bio.link/beastbroak30", "https://bio.link/beastbroak30")
add_contact_part(p_ftr, " · ")
add_contact_part(p_ftr, "akantarip30@gmail.com", "mailto:akantarip30@gmail.com")

output_path = r"C:\Users\akant\Downloads\Antarip_Kar_CV.docx"
doc.save(output_path)
print(f"Saved {output_path} successfully!")
