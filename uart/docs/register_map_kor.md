# UART Register Map (DLAB 기반, 16550 스타일)

이 문서는 UART 모듈의 레지스터 맵을 설명합니다.  
DLAB(Line Control Register\[7\]) 비트에 따라 레지스터 접근 방식이 달라지므로 주의해야 합니다.

---

## 📐 레지스터 주소 맵

| 주소 (Offset) | DLAB = 0           | DLAB = 1           | 접근 | 설명 |
|---------------|---------------------|---------------------|------|------|
| `0x00`        | THR (TX Write)      | DLL (Divisor LSB)   | R/W  | TX 데이터 또는 Baudrate 하위 |
| `0x00`        | RBR (RX Read)       | DLL (Divisor LSB)   | R/W  | RX 데이터 또는 Baudrate 하위 |
| `0x04`        | IER (Interrupt)     | DLH (Divisor MSB)   | R/W  | 인터럽트 설정 or Baudrate 상위 |
| `0x08`        | IIR (Interrupt ID)  | IIR (same)          | R    | 인터럽트 상태 (읽기 전용) |
| `0x08`        | FCR (FIFO Control)  | FCR (same)          | W    | FIFO 설정 (쓰기 전용) |
| `0x0C`        | LCR (Line Control)  | LCR (same)          | R/W  | 데이터 길이, 패리티, 스톱 비트, DLAB 제어 |
| `0x10`        | MCR (Modem Control) | MCR (same)          | R/W  | 모뎀 핸드쉐이크 제어 (선택) |
| `0x14`        | LSR (Line Status)   | LSR (same)          | R    | TX, RX 상태 정보 (THRE, TEMT, DR 등) |
| `0x18`        | MSR (Modem Status)  | MSR (same)          | R    | CTS/RTS 등 상태 (선택) |
| `0x1C`        | SCR (Scratch)       | SCR (same)          | R/W  | 디버깅용, 사용자 정의 |

> ⚠️ 주의: DLAB = LCR[7]  
> - DLAB=1일 때는 주소 `0x00`, `0x04`가 **DLL/DLH**로 동작  
> - DLAB=0일 때는 **THR/RBR, IER**로 동작

---

## 🧾 주요 레지스터 설명

### 🟧 THR (Transmit Holding Register)
- 주소: `0x00`
- 접근: Write only
- 설명: TX 데이터를 쓰면 전송 시작

### 🟦 RBR (Receive Buffer Register)
- 주소: `0x00`
- 접근: Read only
- 설명: 수신된 데이터를 읽음

### 🟩 DLL / DLH (Divisor Latches)
- 주소: `0x00`, `0x04` (DLAB = 1일 때)
- 접근: Read/Write
- 설명: Baudrate 생성기용 분주기 설정 (16비트)

### 🟨 LCR (Line Control Register)
- 주소: `0x0C`
- 접근: Read/Write
- 설명:
  - 데이터 길이 (5~8bit)
  - 패리티 enable / 타입
  - 스톱 비트 설정
  - DLAB 제어 (bit[7])

### 🟦 LSR (Line Status Register)
- 주소: `0x14`
- 접근: Read only
- 주요 비트:
  - bit[0] DR: 수신 데이터 있음
  - bit[5] THRE: THR Empty
  - bit[6] TEMT: TX 완료됨

---

## ✅ 예시: Baudrate 설정 절차

1. LCR[7] = 1 (DLAB 비트 세트)
2. DLL, DLH에 분주기 값 쓰기
3. LCR[7] = 0 (DLAB 비트 클리어)

---

## 📎 기타 참고

- 모든 레지스터는 32비트 정렬 주소 기준 (4-byte aligned)
- TX/RX FIFO, 인터럽트 등은 선택적으로 구현 가능

