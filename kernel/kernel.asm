
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	3c010113          	add	sp,sp,960 # 8000b3c0 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	add	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	add	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	add	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	sllw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	1761                	add	a4,a4,-8 # 200bff8 <_entry-0x7dff4008>
    8000003a:	6318                	ld	a4,0(a4)
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	add	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	sll	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	sll	a3,a3,0x3
    80000050:	0000b717          	auipc	a4,0xb
    80000054:	23070713          	add	a4,a4,560 # 8000b280 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	efe78793          	add	a5,a5,-258 # 80005f60 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	or	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	or	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	add	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	add	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	add	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	add	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd9b0f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	add	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	e2678793          	add	a5,a5,-474 # 80000ed2 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	add	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	or	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srl	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	add	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	add	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	f84a                	sd	s2,48(sp)
    80000108:	0880                	add	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    8000010a:	04c05663          	blez	a2,80000156 <consolewrite+0x56>
    8000010e:	fc26                	sd	s1,56(sp)
    80000110:	f44e                	sd	s3,40(sp)
    80000112:	f052                	sd	s4,32(sp)
    80000114:	ec56                	sd	s5,24(sp)
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	add	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	43a080e7          	jalr	1082(ra) # 80002564 <either_copyin>
    80000132:	03550463          	beq	a0,s5,8000015a <consolewrite+0x5a>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	7e4080e7          	jalr	2020(ra) # 8000091e <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addw	s2,s2,1
    80000144:	0485                	add	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
    8000014c:	74e2                	ld	s1,56(sp)
    8000014e:	79a2                	ld	s3,40(sp)
    80000150:	7a02                	ld	s4,32(sp)
    80000152:	6ae2                	ld	s5,24(sp)
    80000154:	a039                	j	80000162 <consolewrite+0x62>
    80000156:	4901                	li	s2,0
    80000158:	a029                	j	80000162 <consolewrite+0x62>
    8000015a:	74e2                	ld	s1,56(sp)
    8000015c:	79a2                	ld	s3,40(sp)
    8000015e:	7a02                	ld	s4,32(sp)
    80000160:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    80000162:	854a                	mv	a0,s2
    80000164:	60a6                	ld	ra,72(sp)
    80000166:	6406                	ld	s0,64(sp)
    80000168:	7942                	ld	s2,48(sp)
    8000016a:	6161                	add	sp,sp,80
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	add	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	add	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	00013517          	auipc	a0,0x13
    80000190:	23450513          	add	a0,a0,564 # 800133c0 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	aa4080e7          	jalr	-1372(ra) # 80000c38 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00013497          	auipc	s1,0x13
    800001a0:	22448493          	add	s1,s1,548 # 800133c0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	00013917          	auipc	s2,0x13
    800001a8:	2b490913          	add	s2,s2,692 # 80013458 <cons+0x98>
  while(n > 0){
    800001ac:	0d305763          	blez	s3,8000027a <consoleread+0x10c>
    while(cons.r == cons.w){
    800001b0:	0984a783          	lw	a5,152(s1)
    800001b4:	09c4a703          	lw	a4,156(s1)
    800001b8:	0af71c63          	bne	a4,a5,80000270 <consoleread+0x102>
      if(killed(myproc())){
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	88e080e7          	jalr	-1906(ra) # 80001a4a <myproc>
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	1ea080e7          	jalr	490(ra) # 800023ae <killed>
    800001cc:	e52d                	bnez	a0,80000236 <consoleread+0xc8>
      sleep(&cons.r, &cons.lock);
    800001ce:	85a6                	mv	a1,s1
    800001d0:	854a                	mv	a0,s2
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	f2e080e7          	jalr	-210(ra) # 80002100 <sleep>
    while(cons.r == cons.w){
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70de3          	beq	a4,a5,800001bc <consoleread+0x4e>
    800001e6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00013717          	auipc	a4,0x13
    800001ec:	1d870713          	add	a4,a4,472 # 800133c0 <cons>
    800001f0:	0017869b          	addw	a3,a5,1
    800001f4:	08d72c23          	sw	a3,152(a4)
    800001f8:	07f7f693          	and	a3,a5,127
    800001fc:	9736                	add	a4,a4,a3
    800001fe:	01874703          	lbu	a4,24(a4)
    80000202:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80000206:	4691                	li	a3,4
    80000208:	04db8a63          	beq	s7,a3,8000025c <consoleread+0xee>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000020c:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	faf40613          	add	a2,s0,-81
    80000216:	85d2                	mv	a1,s4
    80000218:	8556                	mv	a0,s5
    8000021a:	00002097          	auipc	ra,0x2
    8000021e:	2f4080e7          	jalr	756(ra) # 8000250e <either_copyout>
    80000222:	57fd                	li	a5,-1
    80000224:	04f50a63          	beq	a0,a5,80000278 <consoleread+0x10a>
      break;

    dst++;
    80000228:	0a05                	add	s4,s4,1
    --n;
    8000022a:	39fd                	addw	s3,s3,-1

    if(c == '\n'){
    8000022c:	47a9                	li	a5,10
    8000022e:	06fb8163          	beq	s7,a5,80000290 <consoleread+0x122>
    80000232:	6be2                	ld	s7,24(sp)
    80000234:	bfa5                	j	800001ac <consoleread+0x3e>
        release(&cons.lock);
    80000236:	00013517          	auipc	a0,0x13
    8000023a:	18a50513          	add	a0,a0,394 # 800133c0 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	aae080e7          	jalr	-1362(ra) # 80000cec <release>
        return -1;
    80000246:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000248:	60e6                	ld	ra,88(sp)
    8000024a:	6446                	ld	s0,80(sp)
    8000024c:	64a6                	ld	s1,72(sp)
    8000024e:	6906                	ld	s2,64(sp)
    80000250:	79e2                	ld	s3,56(sp)
    80000252:	7a42                	ld	s4,48(sp)
    80000254:	7aa2                	ld	s5,40(sp)
    80000256:	7b02                	ld	s6,32(sp)
    80000258:	6125                	add	sp,sp,96
    8000025a:	8082                	ret
      if(n < target){
    8000025c:	0009871b          	sext.w	a4,s3
    80000260:	01677a63          	bgeu	a4,s6,80000274 <consoleread+0x106>
        cons.r--;
    80000264:	00013717          	auipc	a4,0x13
    80000268:	1ef72a23          	sw	a5,500(a4) # 80013458 <cons+0x98>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a031                	j	8000027a <consoleread+0x10c>
    80000270:	ec5e                	sd	s7,24(sp)
    80000272:	bf9d                	j	800001e8 <consoleread+0x7a>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	a011                	j	8000027a <consoleread+0x10c>
    80000278:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000027a:	00013517          	auipc	a0,0x13
    8000027e:	14650513          	add	a0,a0,326 # 800133c0 <cons>
    80000282:	00001097          	auipc	ra,0x1
    80000286:	a6a080e7          	jalr	-1430(ra) # 80000cec <release>
  return target - n;
    8000028a:	413b053b          	subw	a0,s6,s3
    8000028e:	bf6d                	j	80000248 <consoleread+0xda>
    80000290:	6be2                	ld	s7,24(sp)
    80000292:	b7e5                	j	8000027a <consoleread+0x10c>

0000000080000294 <consputc>:
{
    80000294:	1141                	add	sp,sp,-16
    80000296:	e406                	sd	ra,8(sp)
    80000298:	e022                	sd	s0,0(sp)
    8000029a:	0800                	add	s0,sp,16
  if(c == BACKSPACE){
    8000029c:	10000793          	li	a5,256
    800002a0:	00f50a63          	beq	a0,a5,800002b4 <consputc+0x20>
    uartputc_sync(c);
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	59c080e7          	jalr	1436(ra) # 80000840 <uartputc_sync>
}
    800002ac:	60a2                	ld	ra,8(sp)
    800002ae:	6402                	ld	s0,0(sp)
    800002b0:	0141                	add	sp,sp,16
    800002b2:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002b4:	4521                	li	a0,8
    800002b6:	00000097          	auipc	ra,0x0
    800002ba:	58a080e7          	jalr	1418(ra) # 80000840 <uartputc_sync>
    800002be:	02000513          	li	a0,32
    800002c2:	00000097          	auipc	ra,0x0
    800002c6:	57e080e7          	jalr	1406(ra) # 80000840 <uartputc_sync>
    800002ca:	4521                	li	a0,8
    800002cc:	00000097          	auipc	ra,0x0
    800002d0:	574080e7          	jalr	1396(ra) # 80000840 <uartputc_sync>
    800002d4:	bfe1                	j	800002ac <consputc+0x18>

00000000800002d6 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002d6:	1101                	add	sp,sp,-32
    800002d8:	ec06                	sd	ra,24(sp)
    800002da:	e822                	sd	s0,16(sp)
    800002dc:	e426                	sd	s1,8(sp)
    800002de:	1000                	add	s0,sp,32
    800002e0:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002e2:	00013517          	auipc	a0,0x13
    800002e6:	0de50513          	add	a0,a0,222 # 800133c0 <cons>
    800002ea:	00001097          	auipc	ra,0x1
    800002ee:	94e080e7          	jalr	-1714(ra) # 80000c38 <acquire>

  switch(c){
    800002f2:	47d5                	li	a5,21
    800002f4:	0af48563          	beq	s1,a5,8000039e <consoleintr+0xc8>
    800002f8:	0297c963          	blt	a5,s1,8000032a <consoleintr+0x54>
    800002fc:	47a1                	li	a5,8
    800002fe:	0ef48c63          	beq	s1,a5,800003f6 <consoleintr+0x120>
    80000302:	47c1                	li	a5,16
    80000304:	10f49f63          	bne	s1,a5,80000422 <consoleintr+0x14c>
  case C('P'):  // Print process list.
    procdump();
    80000308:	00002097          	auipc	ra,0x2
    8000030c:	2b2080e7          	jalr	690(ra) # 800025ba <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000310:	00013517          	auipc	a0,0x13
    80000314:	0b050513          	add	a0,a0,176 # 800133c0 <cons>
    80000318:	00001097          	auipc	ra,0x1
    8000031c:	9d4080e7          	jalr	-1580(ra) # 80000cec <release>
}
    80000320:	60e2                	ld	ra,24(sp)
    80000322:	6442                	ld	s0,16(sp)
    80000324:	64a2                	ld	s1,8(sp)
    80000326:	6105                	add	sp,sp,32
    80000328:	8082                	ret
  switch(c){
    8000032a:	07f00793          	li	a5,127
    8000032e:	0cf48463          	beq	s1,a5,800003f6 <consoleintr+0x120>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000332:	00013717          	auipc	a4,0x13
    80000336:	08e70713          	add	a4,a4,142 # 800133c0 <cons>
    8000033a:	0a072783          	lw	a5,160(a4)
    8000033e:	09872703          	lw	a4,152(a4)
    80000342:	9f99                	subw	a5,a5,a4
    80000344:	07f00713          	li	a4,127
    80000348:	fcf764e3          	bltu	a4,a5,80000310 <consoleintr+0x3a>
      c = (c == '\r') ? '\n' : c;
    8000034c:	47b5                	li	a5,13
    8000034e:	0cf48d63          	beq	s1,a5,80000428 <consoleintr+0x152>
      consputc(c);
    80000352:	8526                	mv	a0,s1
    80000354:	00000097          	auipc	ra,0x0
    80000358:	f40080e7          	jalr	-192(ra) # 80000294 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000035c:	00013797          	auipc	a5,0x13
    80000360:	06478793          	add	a5,a5,100 # 800133c0 <cons>
    80000364:	0a07a683          	lw	a3,160(a5)
    80000368:	0016871b          	addw	a4,a3,1
    8000036c:	0007061b          	sext.w	a2,a4
    80000370:	0ae7a023          	sw	a4,160(a5)
    80000374:	07f6f693          	and	a3,a3,127
    80000378:	97b6                	add	a5,a5,a3
    8000037a:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000037e:	47a9                	li	a5,10
    80000380:	0cf48b63          	beq	s1,a5,80000456 <consoleintr+0x180>
    80000384:	4791                	li	a5,4
    80000386:	0cf48863          	beq	s1,a5,80000456 <consoleintr+0x180>
    8000038a:	00013797          	auipc	a5,0x13
    8000038e:	0ce7a783          	lw	a5,206(a5) # 80013458 <cons+0x98>
    80000392:	9f1d                	subw	a4,a4,a5
    80000394:	08000793          	li	a5,128
    80000398:	f6f71ce3          	bne	a4,a5,80000310 <consoleintr+0x3a>
    8000039c:	a86d                	j	80000456 <consoleintr+0x180>
    8000039e:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    800003a0:	00013717          	auipc	a4,0x13
    800003a4:	02070713          	add	a4,a4,32 # 800133c0 <cons>
    800003a8:	0a072783          	lw	a5,160(a4)
    800003ac:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003b0:	00013497          	auipc	s1,0x13
    800003b4:	01048493          	add	s1,s1,16 # 800133c0 <cons>
    while(cons.e != cons.w &&
    800003b8:	4929                	li	s2,10
    800003ba:	02f70a63          	beq	a4,a5,800003ee <consoleintr+0x118>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003be:	37fd                	addw	a5,a5,-1
    800003c0:	07f7f713          	and	a4,a5,127
    800003c4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003c6:	01874703          	lbu	a4,24(a4)
    800003ca:	03270463          	beq	a4,s2,800003f2 <consoleintr+0x11c>
      cons.e--;
    800003ce:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	00000097          	auipc	ra,0x0
    800003da:	ebe080e7          	jalr	-322(ra) # 80000294 <consputc>
    while(cons.e != cons.w &&
    800003de:	0a04a783          	lw	a5,160(s1)
    800003e2:	09c4a703          	lw	a4,156(s1)
    800003e6:	fcf71ce3          	bne	a4,a5,800003be <consoleintr+0xe8>
    800003ea:	6902                	ld	s2,0(sp)
    800003ec:	b715                	j	80000310 <consoleintr+0x3a>
    800003ee:	6902                	ld	s2,0(sp)
    800003f0:	b705                	j	80000310 <consoleintr+0x3a>
    800003f2:	6902                	ld	s2,0(sp)
    800003f4:	bf31                	j	80000310 <consoleintr+0x3a>
    if(cons.e != cons.w){
    800003f6:	00013717          	auipc	a4,0x13
    800003fa:	fca70713          	add	a4,a4,-54 # 800133c0 <cons>
    800003fe:	0a072783          	lw	a5,160(a4)
    80000402:	09c72703          	lw	a4,156(a4)
    80000406:	f0f705e3          	beq	a4,a5,80000310 <consoleintr+0x3a>
      cons.e--;
    8000040a:	37fd                	addw	a5,a5,-1
    8000040c:	00013717          	auipc	a4,0x13
    80000410:	04f72a23          	sw	a5,84(a4) # 80013460 <cons+0xa0>
      consputc(BACKSPACE);
    80000414:	10000513          	li	a0,256
    80000418:	00000097          	auipc	ra,0x0
    8000041c:	e7c080e7          	jalr	-388(ra) # 80000294 <consputc>
    80000420:	bdc5                	j	80000310 <consoleintr+0x3a>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000422:	ee0487e3          	beqz	s1,80000310 <consoleintr+0x3a>
    80000426:	b731                	j	80000332 <consoleintr+0x5c>
      consputc(c);
    80000428:	4529                	li	a0,10
    8000042a:	00000097          	auipc	ra,0x0
    8000042e:	e6a080e7          	jalr	-406(ra) # 80000294 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000432:	00013797          	auipc	a5,0x13
    80000436:	f8e78793          	add	a5,a5,-114 # 800133c0 <cons>
    8000043a:	0a07a703          	lw	a4,160(a5)
    8000043e:	0017069b          	addw	a3,a4,1
    80000442:	0006861b          	sext.w	a2,a3
    80000446:	0ad7a023          	sw	a3,160(a5)
    8000044a:	07f77713          	and	a4,a4,127
    8000044e:	97ba                	add	a5,a5,a4
    80000450:	4729                	li	a4,10
    80000452:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000456:	00013797          	auipc	a5,0x13
    8000045a:	00c7a323          	sw	a2,6(a5) # 8001345c <cons+0x9c>
        wakeup(&cons.r);
    8000045e:	00013517          	auipc	a0,0x13
    80000462:	ffa50513          	add	a0,a0,-6 # 80013458 <cons+0x98>
    80000466:	00002097          	auipc	ra,0x2
    8000046a:	d04080e7          	jalr	-764(ra) # 8000216a <wakeup>
    8000046e:	b54d                	j	80000310 <consoleintr+0x3a>

0000000080000470 <consoleinit>:

void
consoleinit(void)
{
    80000470:	1141                	add	sp,sp,-16
    80000472:	e406                	sd	ra,8(sp)
    80000474:	e022                	sd	s0,0(sp)
    80000476:	0800                	add	s0,sp,16
  initlock(&cons.lock, "cons");
    80000478:	00008597          	auipc	a1,0x8
    8000047c:	b8858593          	add	a1,a1,-1144 # 80008000 <etext>
    80000480:	00013517          	auipc	a0,0x13
    80000484:	f4050513          	add	a0,a0,-192 # 800133c0 <cons>
    80000488:	00000097          	auipc	ra,0x0
    8000048c:	720080e7          	jalr	1824(ra) # 80000ba8 <initlock>

  uartinit();
    80000490:	00000097          	auipc	ra,0x0
    80000494:	354080e7          	jalr	852(ra) # 800007e4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000498:	00023797          	auipc	a5,0x23
    8000049c:	6c078793          	add	a5,a5,1728 # 80023b58 <devsw>
    800004a0:	00000717          	auipc	a4,0x0
    800004a4:	cce70713          	add	a4,a4,-818 # 8000016e <consoleread>
    800004a8:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004aa:	00000717          	auipc	a4,0x0
    800004ae:	c5670713          	add	a4,a4,-938 # 80000100 <consolewrite>
    800004b2:	ef98                	sd	a4,24(a5)
}
    800004b4:	60a2                	ld	ra,8(sp)
    800004b6:	6402                	ld	s0,0(sp)
    800004b8:	0141                	add	sp,sp,16
    800004ba:	8082                	ret

00000000800004bc <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004bc:	7179                	add	sp,sp,-48
    800004be:	f406                	sd	ra,40(sp)
    800004c0:	f022                	sd	s0,32(sp)
    800004c2:	1800                	add	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004c4:	c219                	beqz	a2,800004ca <printint+0xe>
    800004c6:	08054963          	bltz	a0,80000558 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ca:	2501                	sext.w	a0,a0
    800004cc:	4881                	li	a7,0
    800004ce:	fd040693          	add	a3,s0,-48

  i = 0;
    800004d2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004d4:	2581                	sext.w	a1,a1
    800004d6:	00008617          	auipc	a2,0x8
    800004da:	b5a60613          	add	a2,a2,-1190 # 80008030 <digits>
    800004de:	883a                	mv	a6,a4
    800004e0:	2705                	addw	a4,a4,1
    800004e2:	02b577bb          	remuw	a5,a0,a1
    800004e6:	1782                	sll	a5,a5,0x20
    800004e8:	9381                	srl	a5,a5,0x20
    800004ea:	97b2                	add	a5,a5,a2
    800004ec:	0007c783          	lbu	a5,0(a5)
    800004f0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004f4:	0005079b          	sext.w	a5,a0
    800004f8:	02b5553b          	divuw	a0,a0,a1
    800004fc:	0685                	add	a3,a3,1
    800004fe:	feb7f0e3          	bgeu	a5,a1,800004de <printint+0x22>

  if(sign)
    80000502:	00088c63          	beqz	a7,8000051a <printint+0x5e>
    buf[i++] = '-';
    80000506:	fe070793          	add	a5,a4,-32
    8000050a:	00878733          	add	a4,a5,s0
    8000050e:	02d00793          	li	a5,45
    80000512:	fef70823          	sb	a5,-16(a4)
    80000516:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
    8000051a:	02e05b63          	blez	a4,80000550 <printint+0x94>
    8000051e:	ec26                	sd	s1,24(sp)
    80000520:	e84a                	sd	s2,16(sp)
    80000522:	fd040793          	add	a5,s0,-48
    80000526:	00e784b3          	add	s1,a5,a4
    8000052a:	fff78913          	add	s2,a5,-1
    8000052e:	993a                	add	s2,s2,a4
    80000530:	377d                	addw	a4,a4,-1
    80000532:	1702                	sll	a4,a4,0x20
    80000534:	9301                	srl	a4,a4,0x20
    80000536:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000053a:	fff4c503          	lbu	a0,-1(s1)
    8000053e:	00000097          	auipc	ra,0x0
    80000542:	d56080e7          	jalr	-682(ra) # 80000294 <consputc>
  while(--i >= 0)
    80000546:	14fd                	add	s1,s1,-1
    80000548:	ff2499e3          	bne	s1,s2,8000053a <printint+0x7e>
    8000054c:	64e2                	ld	s1,24(sp)
    8000054e:	6942                	ld	s2,16(sp)
}
    80000550:	70a2                	ld	ra,40(sp)
    80000552:	7402                	ld	s0,32(sp)
    80000554:	6145                	add	sp,sp,48
    80000556:	8082                	ret
    x = -xx;
    80000558:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000055c:	4885                	li	a7,1
    x = -xx;
    8000055e:	bf85                	j	800004ce <printint+0x12>

0000000080000560 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000560:	1101                	add	sp,sp,-32
    80000562:	ec06                	sd	ra,24(sp)
    80000564:	e822                	sd	s0,16(sp)
    80000566:	e426                	sd	s1,8(sp)
    80000568:	1000                	add	s0,sp,32
    8000056a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000056c:	00013797          	auipc	a5,0x13
    80000570:	f007aa23          	sw	zero,-236(a5) # 80013480 <pr+0x18>
  printf("panic: ");
    80000574:	00008517          	auipc	a0,0x8
    80000578:	a9450513          	add	a0,a0,-1388 # 80008008 <etext+0x8>
    8000057c:	00000097          	auipc	ra,0x0
    80000580:	02e080e7          	jalr	46(ra) # 800005aa <printf>
  printf(s);
    80000584:	8526                	mv	a0,s1
    80000586:	00000097          	auipc	ra,0x0
    8000058a:	024080e7          	jalr	36(ra) # 800005aa <printf>
  printf("\n");
    8000058e:	00008517          	auipc	a0,0x8
    80000592:	b2a50513          	add	a0,a0,-1238 # 800080b8 <digits+0x88>
    80000596:	00000097          	auipc	ra,0x0
    8000059a:	014080e7          	jalr	20(ra) # 800005aa <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000059e:	4785                	li	a5,1
    800005a0:	0000b717          	auipc	a4,0xb
    800005a4:	caf72023          	sw	a5,-864(a4) # 8000b240 <panicked>
  for(;;)
    800005a8:	a001                	j	800005a8 <panic+0x48>

00000000800005aa <printf>:
{
    800005aa:	7131                	add	sp,sp,-192
    800005ac:	fc86                	sd	ra,120(sp)
    800005ae:	f8a2                	sd	s0,112(sp)
    800005b0:	e8d2                	sd	s4,80(sp)
    800005b2:	f06a                	sd	s10,32(sp)
    800005b4:	0100                	add	s0,sp,128
    800005b6:	8a2a                	mv	s4,a0
    800005b8:	e40c                	sd	a1,8(s0)
    800005ba:	e810                	sd	a2,16(s0)
    800005bc:	ec14                	sd	a3,24(s0)
    800005be:	f018                	sd	a4,32(s0)
    800005c0:	f41c                	sd	a5,40(s0)
    800005c2:	03043823          	sd	a6,48(s0)
    800005c6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ca:	00013d17          	auipc	s10,0x13
    800005ce:	eb6d2d03          	lw	s10,-330(s10) # 80013480 <pr+0x18>
  if(locking)
    800005d2:	040d1463          	bnez	s10,8000061a <printf+0x70>
  if (fmt == 0)
    800005d6:	040a0b63          	beqz	s4,8000062c <printf+0x82>
  va_start(ap, fmt);
    800005da:	00840793          	add	a5,s0,8
    800005de:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005e2:	000a4503          	lbu	a0,0(s4)
    800005e6:	18050b63          	beqz	a0,8000077c <printf+0x1d2>
    800005ea:	f4a6                	sd	s1,104(sp)
    800005ec:	f0ca                	sd	s2,96(sp)
    800005ee:	ecce                	sd	s3,88(sp)
    800005f0:	e4d6                	sd	s5,72(sp)
    800005f2:	e0da                	sd	s6,64(sp)
    800005f4:	fc5e                	sd	s7,56(sp)
    800005f6:	f862                	sd	s8,48(sp)
    800005f8:	f466                	sd	s9,40(sp)
    800005fa:	ec6e                	sd	s11,24(sp)
    800005fc:	4981                	li	s3,0
    if(c != '%'){
    800005fe:	02500b13          	li	s6,37
    switch(c){
    80000602:	07000b93          	li	s7,112
  consputc('x');
    80000606:	4cc1                	li	s9,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000608:	00008a97          	auipc	s5,0x8
    8000060c:	a28a8a93          	add	s5,s5,-1496 # 80008030 <digits>
    switch(c){
    80000610:	07300c13          	li	s8,115
    80000614:	06400d93          	li	s11,100
    80000618:	a0b1                	j	80000664 <printf+0xba>
    acquire(&pr.lock);
    8000061a:	00013517          	auipc	a0,0x13
    8000061e:	e4e50513          	add	a0,a0,-434 # 80013468 <pr>
    80000622:	00000097          	auipc	ra,0x0
    80000626:	616080e7          	jalr	1558(ra) # 80000c38 <acquire>
    8000062a:	b775                	j	800005d6 <printf+0x2c>
    8000062c:	f4a6                	sd	s1,104(sp)
    8000062e:	f0ca                	sd	s2,96(sp)
    80000630:	ecce                	sd	s3,88(sp)
    80000632:	e4d6                	sd	s5,72(sp)
    80000634:	e0da                	sd	s6,64(sp)
    80000636:	fc5e                	sd	s7,56(sp)
    80000638:	f862                	sd	s8,48(sp)
    8000063a:	f466                	sd	s9,40(sp)
    8000063c:	ec6e                	sd	s11,24(sp)
    panic("null fmt");
    8000063e:	00008517          	auipc	a0,0x8
    80000642:	9da50513          	add	a0,a0,-1574 # 80008018 <etext+0x18>
    80000646:	00000097          	auipc	ra,0x0
    8000064a:	f1a080e7          	jalr	-230(ra) # 80000560 <panic>
      consputc(c);
    8000064e:	00000097          	auipc	ra,0x0
    80000652:	c46080e7          	jalr	-954(ra) # 80000294 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000656:	2985                	addw	s3,s3,1
    80000658:	013a07b3          	add	a5,s4,s3
    8000065c:	0007c503          	lbu	a0,0(a5)
    80000660:	10050563          	beqz	a0,8000076a <printf+0x1c0>
    if(c != '%'){
    80000664:	ff6515e3          	bne	a0,s6,8000064e <printf+0xa4>
    c = fmt[++i] & 0xff;
    80000668:	2985                	addw	s3,s3,1
    8000066a:	013a07b3          	add	a5,s4,s3
    8000066e:	0007c783          	lbu	a5,0(a5)
    80000672:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000676:	10078b63          	beqz	a5,8000078c <printf+0x1e2>
    switch(c){
    8000067a:	05778a63          	beq	a5,s7,800006ce <printf+0x124>
    8000067e:	02fbf663          	bgeu	s7,a5,800006aa <printf+0x100>
    80000682:	09878863          	beq	a5,s8,80000712 <printf+0x168>
    80000686:	07800713          	li	a4,120
    8000068a:	0ce79563          	bne	a5,a4,80000754 <printf+0x1aa>
      printint(va_arg(ap, int), 16, 1);
    8000068e:	f8843783          	ld	a5,-120(s0)
    80000692:	00878713          	add	a4,a5,8
    80000696:	f8e43423          	sd	a4,-120(s0)
    8000069a:	4605                	li	a2,1
    8000069c:	85e6                	mv	a1,s9
    8000069e:	4388                	lw	a0,0(a5)
    800006a0:	00000097          	auipc	ra,0x0
    800006a4:	e1c080e7          	jalr	-484(ra) # 800004bc <printint>
      break;
    800006a8:	b77d                	j	80000656 <printf+0xac>
    switch(c){
    800006aa:	09678f63          	beq	a5,s6,80000748 <printf+0x19e>
    800006ae:	0bb79363          	bne	a5,s11,80000754 <printf+0x1aa>
      printint(va_arg(ap, int), 10, 1);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	add	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4605                	li	a2,1
    800006c0:	45a9                	li	a1,10
    800006c2:	4388                	lw	a0,0(a5)
    800006c4:	00000097          	auipc	ra,0x0
    800006c8:	df8080e7          	jalr	-520(ra) # 800004bc <printint>
      break;
    800006cc:	b769                	j	80000656 <printf+0xac>
      printptr(va_arg(ap, uint64));
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	add	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006de:	03000513          	li	a0,48
    800006e2:	00000097          	auipc	ra,0x0
    800006e6:	bb2080e7          	jalr	-1102(ra) # 80000294 <consputc>
  consputc('x');
    800006ea:	07800513          	li	a0,120
    800006ee:	00000097          	auipc	ra,0x0
    800006f2:	ba6080e7          	jalr	-1114(ra) # 80000294 <consputc>
    800006f6:	84e6                	mv	s1,s9
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f8:	03c95793          	srl	a5,s2,0x3c
    800006fc:	97d6                	add	a5,a5,s5
    800006fe:	0007c503          	lbu	a0,0(a5)
    80000702:	00000097          	auipc	ra,0x0
    80000706:	b92080e7          	jalr	-1134(ra) # 80000294 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000070a:	0912                	sll	s2,s2,0x4
    8000070c:	34fd                	addw	s1,s1,-1
    8000070e:	f4ed                	bnez	s1,800006f8 <printf+0x14e>
    80000710:	b799                	j	80000656 <printf+0xac>
      if((s = va_arg(ap, char*)) == 0)
    80000712:	f8843783          	ld	a5,-120(s0)
    80000716:	00878713          	add	a4,a5,8
    8000071a:	f8e43423          	sd	a4,-120(s0)
    8000071e:	6384                	ld	s1,0(a5)
    80000720:	cc89                	beqz	s1,8000073a <printf+0x190>
      for(; *s; s++)
    80000722:	0004c503          	lbu	a0,0(s1)
    80000726:	d905                	beqz	a0,80000656 <printf+0xac>
        consputc(*s);
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b6c080e7          	jalr	-1172(ra) # 80000294 <consputc>
      for(; *s; s++)
    80000730:	0485                	add	s1,s1,1
    80000732:	0004c503          	lbu	a0,0(s1)
    80000736:	f96d                	bnez	a0,80000728 <printf+0x17e>
    80000738:	bf39                	j	80000656 <printf+0xac>
        s = "(null)";
    8000073a:	00008497          	auipc	s1,0x8
    8000073e:	8d648493          	add	s1,s1,-1834 # 80008010 <etext+0x10>
      for(; *s; s++)
    80000742:	02800513          	li	a0,40
    80000746:	b7cd                	j	80000728 <printf+0x17e>
      consputc('%');
    80000748:	855a                	mv	a0,s6
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	b4a080e7          	jalr	-1206(ra) # 80000294 <consputc>
      break;
    80000752:	b711                	j	80000656 <printf+0xac>
      consputc('%');
    80000754:	855a                	mv	a0,s6
    80000756:	00000097          	auipc	ra,0x0
    8000075a:	b3e080e7          	jalr	-1218(ra) # 80000294 <consputc>
      consputc(c);
    8000075e:	8526                	mv	a0,s1
    80000760:	00000097          	auipc	ra,0x0
    80000764:	b34080e7          	jalr	-1228(ra) # 80000294 <consputc>
      break;
    80000768:	b5fd                	j	80000656 <printf+0xac>
    8000076a:	74a6                	ld	s1,104(sp)
    8000076c:	7906                	ld	s2,96(sp)
    8000076e:	69e6                	ld	s3,88(sp)
    80000770:	6aa6                	ld	s5,72(sp)
    80000772:	6b06                	ld	s6,64(sp)
    80000774:	7be2                	ld	s7,56(sp)
    80000776:	7c42                	ld	s8,48(sp)
    80000778:	7ca2                	ld	s9,40(sp)
    8000077a:	6de2                	ld	s11,24(sp)
  if(locking)
    8000077c:	020d1263          	bnez	s10,800007a0 <printf+0x1f6>
}
    80000780:	70e6                	ld	ra,120(sp)
    80000782:	7446                	ld	s0,112(sp)
    80000784:	6a46                	ld	s4,80(sp)
    80000786:	7d02                	ld	s10,32(sp)
    80000788:	6129                	add	sp,sp,192
    8000078a:	8082                	ret
    8000078c:	74a6                	ld	s1,104(sp)
    8000078e:	7906                	ld	s2,96(sp)
    80000790:	69e6                	ld	s3,88(sp)
    80000792:	6aa6                	ld	s5,72(sp)
    80000794:	6b06                	ld	s6,64(sp)
    80000796:	7be2                	ld	s7,56(sp)
    80000798:	7c42                	ld	s8,48(sp)
    8000079a:	7ca2                	ld	s9,40(sp)
    8000079c:	6de2                	ld	s11,24(sp)
    8000079e:	bff9                	j	8000077c <printf+0x1d2>
    release(&pr.lock);
    800007a0:	00013517          	auipc	a0,0x13
    800007a4:	cc850513          	add	a0,a0,-824 # 80013468 <pr>
    800007a8:	00000097          	auipc	ra,0x0
    800007ac:	544080e7          	jalr	1348(ra) # 80000cec <release>
}
    800007b0:	bfc1                	j	80000780 <printf+0x1d6>

00000000800007b2 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007b2:	1101                	add	sp,sp,-32
    800007b4:	ec06                	sd	ra,24(sp)
    800007b6:	e822                	sd	s0,16(sp)
    800007b8:	e426                	sd	s1,8(sp)
    800007ba:	1000                	add	s0,sp,32
  initlock(&pr.lock, "pr");
    800007bc:	00013497          	auipc	s1,0x13
    800007c0:	cac48493          	add	s1,s1,-852 # 80013468 <pr>
    800007c4:	00008597          	auipc	a1,0x8
    800007c8:	86458593          	add	a1,a1,-1948 # 80008028 <etext+0x28>
    800007cc:	8526                	mv	a0,s1
    800007ce:	00000097          	auipc	ra,0x0
    800007d2:	3da080e7          	jalr	986(ra) # 80000ba8 <initlock>
  pr.locking = 1;
    800007d6:	4785                	li	a5,1
    800007d8:	cc9c                	sw	a5,24(s1)
}
    800007da:	60e2                	ld	ra,24(sp)
    800007dc:	6442                	ld	s0,16(sp)
    800007de:	64a2                	ld	s1,8(sp)
    800007e0:	6105                	add	sp,sp,32
    800007e2:	8082                	ret

00000000800007e4 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007e4:	1141                	add	sp,sp,-16
    800007e6:	e406                	sd	ra,8(sp)
    800007e8:	e022                	sd	s0,0(sp)
    800007ea:	0800                	add	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ec:	100007b7          	lui	a5,0x10000
    800007f0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007f4:	10000737          	lui	a4,0x10000
    800007f8:	f8000693          	li	a3,-128
    800007fc:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000800:	468d                	li	a3,3
    80000802:	10000637          	lui	a2,0x10000
    80000806:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000080a:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000080e:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000812:	10000737          	lui	a4,0x10000
    80000816:	461d                	li	a2,7
    80000818:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000081c:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000820:	00008597          	auipc	a1,0x8
    80000824:	82858593          	add	a1,a1,-2008 # 80008048 <digits+0x18>
    80000828:	00013517          	auipc	a0,0x13
    8000082c:	c6050513          	add	a0,a0,-928 # 80013488 <uart_tx_lock>
    80000830:	00000097          	auipc	ra,0x0
    80000834:	378080e7          	jalr	888(ra) # 80000ba8 <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	add	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000840:	1101                	add	sp,sp,-32
    80000842:	ec06                	sd	ra,24(sp)
    80000844:	e822                	sd	s0,16(sp)
    80000846:	e426                	sd	s1,8(sp)
    80000848:	1000                	add	s0,sp,32
    8000084a:	84aa                	mv	s1,a0
  push_off();
    8000084c:	00000097          	auipc	ra,0x0
    80000850:	3a0080e7          	jalr	928(ra) # 80000bec <push_off>

  if(panicked){
    80000854:	0000b797          	auipc	a5,0xb
    80000858:	9ec7a783          	lw	a5,-1556(a5) # 8000b240 <panicked>
    8000085c:	eb85                	bnez	a5,8000088c <uartputc_sync+0x4c>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000085e:	10000737          	lui	a4,0x10000
    80000862:	0715                	add	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000864:	00074783          	lbu	a5,0(a4)
    80000868:	0207f793          	and	a5,a5,32
    8000086c:	dfe5                	beqz	a5,80000864 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000086e:	0ff4f513          	zext.b	a0,s1
    80000872:	100007b7          	lui	a5,0x10000
    80000876:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000087a:	00000097          	auipc	ra,0x0
    8000087e:	412080e7          	jalr	1042(ra) # 80000c8c <pop_off>
}
    80000882:	60e2                	ld	ra,24(sp)
    80000884:	6442                	ld	s0,16(sp)
    80000886:	64a2                	ld	s1,8(sp)
    80000888:	6105                	add	sp,sp,32
    8000088a:	8082                	ret
    for(;;)
    8000088c:	a001                	j	8000088c <uartputc_sync+0x4c>

000000008000088e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000088e:	0000b797          	auipc	a5,0xb
    80000892:	9ba7b783          	ld	a5,-1606(a5) # 8000b248 <uart_tx_r>
    80000896:	0000b717          	auipc	a4,0xb
    8000089a:	9ba73703          	ld	a4,-1606(a4) # 8000b250 <uart_tx_w>
    8000089e:	06f70f63          	beq	a4,a5,8000091c <uartstart+0x8e>
{
    800008a2:	7139                	add	sp,sp,-64
    800008a4:	fc06                	sd	ra,56(sp)
    800008a6:	f822                	sd	s0,48(sp)
    800008a8:	f426                	sd	s1,40(sp)
    800008aa:	f04a                	sd	s2,32(sp)
    800008ac:	ec4e                	sd	s3,24(sp)
    800008ae:	e852                	sd	s4,16(sp)
    800008b0:	e456                	sd	s5,8(sp)
    800008b2:	e05a                	sd	s6,0(sp)
    800008b4:	0080                	add	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008b6:	10000937          	lui	s2,0x10000
    800008ba:	0915                	add	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008bc:	00013a97          	auipc	s5,0x13
    800008c0:	bcca8a93          	add	s5,s5,-1076 # 80013488 <uart_tx_lock>
    uart_tx_r += 1;
    800008c4:	0000b497          	auipc	s1,0xb
    800008c8:	98448493          	add	s1,s1,-1660 # 8000b248 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008cc:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008d0:	0000b997          	auipc	s3,0xb
    800008d4:	98098993          	add	s3,s3,-1664 # 8000b250 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008d8:	00094703          	lbu	a4,0(s2)
    800008dc:	02077713          	and	a4,a4,32
    800008e0:	c705                	beqz	a4,80000908 <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008e2:	01f7f713          	and	a4,a5,31
    800008e6:	9756                	add	a4,a4,s5
    800008e8:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008ec:	0785                	add	a5,a5,1
    800008ee:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008f0:	8526                	mv	a0,s1
    800008f2:	00002097          	auipc	ra,0x2
    800008f6:	878080e7          	jalr	-1928(ra) # 8000216a <wakeup>
    WriteReg(THR, c);
    800008fa:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008fe:	609c                	ld	a5,0(s1)
    80000900:	0009b703          	ld	a4,0(s3)
    80000904:	fcf71ae3          	bne	a4,a5,800008d8 <uartstart+0x4a>
  }
}
    80000908:	70e2                	ld	ra,56(sp)
    8000090a:	7442                	ld	s0,48(sp)
    8000090c:	74a2                	ld	s1,40(sp)
    8000090e:	7902                	ld	s2,32(sp)
    80000910:	69e2                	ld	s3,24(sp)
    80000912:	6a42                	ld	s4,16(sp)
    80000914:	6aa2                	ld	s5,8(sp)
    80000916:	6b02                	ld	s6,0(sp)
    80000918:	6121                	add	sp,sp,64
    8000091a:	8082                	ret
    8000091c:	8082                	ret

000000008000091e <uartputc>:
{
    8000091e:	7179                	add	sp,sp,-48
    80000920:	f406                	sd	ra,40(sp)
    80000922:	f022                	sd	s0,32(sp)
    80000924:	ec26                	sd	s1,24(sp)
    80000926:	e84a                	sd	s2,16(sp)
    80000928:	e44e                	sd	s3,8(sp)
    8000092a:	e052                	sd	s4,0(sp)
    8000092c:	1800                	add	s0,sp,48
    8000092e:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000930:	00013517          	auipc	a0,0x13
    80000934:	b5850513          	add	a0,a0,-1192 # 80013488 <uart_tx_lock>
    80000938:	00000097          	auipc	ra,0x0
    8000093c:	300080e7          	jalr	768(ra) # 80000c38 <acquire>
  if(panicked){
    80000940:	0000b797          	auipc	a5,0xb
    80000944:	9007a783          	lw	a5,-1792(a5) # 8000b240 <panicked>
    80000948:	e7c9                	bnez	a5,800009d2 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000094a:	0000b717          	auipc	a4,0xb
    8000094e:	90673703          	ld	a4,-1786(a4) # 8000b250 <uart_tx_w>
    80000952:	0000b797          	auipc	a5,0xb
    80000956:	8f67b783          	ld	a5,-1802(a5) # 8000b248 <uart_tx_r>
    8000095a:	02078793          	add	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000095e:	00013997          	auipc	s3,0x13
    80000962:	b2a98993          	add	s3,s3,-1238 # 80013488 <uart_tx_lock>
    80000966:	0000b497          	auipc	s1,0xb
    8000096a:	8e248493          	add	s1,s1,-1822 # 8000b248 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096e:	0000b917          	auipc	s2,0xb
    80000972:	8e290913          	add	s2,s2,-1822 # 8000b250 <uart_tx_w>
    80000976:	00e79f63          	bne	a5,a4,80000994 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	85ce                	mv	a1,s3
    8000097c:	8526                	mv	a0,s1
    8000097e:	00001097          	auipc	ra,0x1
    80000982:	782080e7          	jalr	1922(ra) # 80002100 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00093703          	ld	a4,0(s2)
    8000098a:	609c                	ld	a5,0(s1)
    8000098c:	02078793          	add	a5,a5,32
    80000990:	fee785e3          	beq	a5,a4,8000097a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000994:	00013497          	auipc	s1,0x13
    80000998:	af448493          	add	s1,s1,-1292 # 80013488 <uart_tx_lock>
    8000099c:	01f77793          	and	a5,a4,31
    800009a0:	97a6                	add	a5,a5,s1
    800009a2:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009a6:	0705                	add	a4,a4,1
    800009a8:	0000b797          	auipc	a5,0xb
    800009ac:	8ae7b423          	sd	a4,-1880(a5) # 8000b250 <uart_tx_w>
  uartstart();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	ede080e7          	jalr	-290(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    800009b8:	8526                	mv	a0,s1
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	332080e7          	jalr	818(ra) # 80000cec <release>
}
    800009c2:	70a2                	ld	ra,40(sp)
    800009c4:	7402                	ld	s0,32(sp)
    800009c6:	64e2                	ld	s1,24(sp)
    800009c8:	6942                	ld	s2,16(sp)
    800009ca:	69a2                	ld	s3,8(sp)
    800009cc:	6a02                	ld	s4,0(sp)
    800009ce:	6145                	add	sp,sp,48
    800009d0:	8082                	ret
    for(;;)
    800009d2:	a001                	j	800009d2 <uartputc+0xb4>

00000000800009d4 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009d4:	1141                	add	sp,sp,-16
    800009d6:	e422                	sd	s0,8(sp)
    800009d8:	0800                	add	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009da:	100007b7          	lui	a5,0x10000
    800009de:	0795                	add	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009e0:	0007c783          	lbu	a5,0(a5)
    800009e4:	8b85                	and	a5,a5,1
    800009e6:	cb81                	beqz	a5,800009f6 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009e8:	100007b7          	lui	a5,0x10000
    800009ec:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009f0:	6422                	ld	s0,8(sp)
    800009f2:	0141                	add	sp,sp,16
    800009f4:	8082                	ret
    return -1;
    800009f6:	557d                	li	a0,-1
    800009f8:	bfe5                	j	800009f0 <uartgetc+0x1c>

00000000800009fa <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009fa:	1101                	add	sp,sp,-32
    800009fc:	ec06                	sd	ra,24(sp)
    800009fe:	e822                	sd	s0,16(sp)
    80000a00:	e426                	sd	s1,8(sp)
    80000a02:	1000                	add	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a04:	54fd                	li	s1,-1
    80000a06:	a029                	j	80000a10 <uartintr+0x16>
      break;
    consoleintr(c);
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	8ce080e7          	jalr	-1842(ra) # 800002d6 <consoleintr>
    int c = uartgetc();
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	fc4080e7          	jalr	-60(ra) # 800009d4 <uartgetc>
    if(c == -1)
    80000a18:	fe9518e3          	bne	a0,s1,80000a08 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a1c:	00013497          	auipc	s1,0x13
    80000a20:	a6c48493          	add	s1,s1,-1428 # 80013488 <uart_tx_lock>
    80000a24:	8526                	mv	a0,s1
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	212080e7          	jalr	530(ra) # 80000c38 <acquire>
  uartstart();
    80000a2e:	00000097          	auipc	ra,0x0
    80000a32:	e60080e7          	jalr	-416(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    80000a36:	8526                	mv	a0,s1
    80000a38:	00000097          	auipc	ra,0x0
    80000a3c:	2b4080e7          	jalr	692(ra) # 80000cec <release>
}
    80000a40:	60e2                	ld	ra,24(sp)
    80000a42:	6442                	ld	s0,16(sp)
    80000a44:	64a2                	ld	s1,8(sp)
    80000a46:	6105                	add	sp,sp,32
    80000a48:	8082                	ret

0000000080000a4a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a4a:	1101                	add	sp,sp,-32
    80000a4c:	ec06                	sd	ra,24(sp)
    80000a4e:	e822                	sd	s0,16(sp)
    80000a50:	e426                	sd	s1,8(sp)
    80000a52:	e04a                	sd	s2,0(sp)
    80000a54:	1000                	add	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a56:	03451793          	sll	a5,a0,0x34
    80000a5a:	ebb9                	bnez	a5,80000ab0 <kfree+0x66>
    80000a5c:	84aa                	mv	s1,a0
    80000a5e:	00024797          	auipc	a5,0x24
    80000a62:	29278793          	add	a5,a5,658 # 80024cf0 <end>
    80000a66:	04f56563          	bltu	a0,a5,80000ab0 <kfree+0x66>
    80000a6a:	47c5                	li	a5,17
    80000a6c:	07ee                	sll	a5,a5,0x1b
    80000a6e:	04f57163          	bgeu	a0,a5,80000ab0 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a72:	6605                	lui	a2,0x1
    80000a74:	4585                	li	a1,1
    80000a76:	00000097          	auipc	ra,0x0
    80000a7a:	2be080e7          	jalr	702(ra) # 80000d34 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a7e:	00013917          	auipc	s2,0x13
    80000a82:	a4290913          	add	s2,s2,-1470 # 800134c0 <kmem>
    80000a86:	854a                	mv	a0,s2
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	1b0080e7          	jalr	432(ra) # 80000c38 <acquire>
  r->next = kmem.freelist;
    80000a90:	01893783          	ld	a5,24(s2)
    80000a94:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a96:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a9a:	854a                	mv	a0,s2
    80000a9c:	00000097          	auipc	ra,0x0
    80000aa0:	250080e7          	jalr	592(ra) # 80000cec <release>
}
    80000aa4:	60e2                	ld	ra,24(sp)
    80000aa6:	6442                	ld	s0,16(sp)
    80000aa8:	64a2                	ld	s1,8(sp)
    80000aaa:	6902                	ld	s2,0(sp)
    80000aac:	6105                	add	sp,sp,32
    80000aae:	8082                	ret
    panic("kfree");
    80000ab0:	00007517          	auipc	a0,0x7
    80000ab4:	5a050513          	add	a0,a0,1440 # 80008050 <digits+0x20>
    80000ab8:	00000097          	auipc	ra,0x0
    80000abc:	aa8080e7          	jalr	-1368(ra) # 80000560 <panic>

0000000080000ac0 <freerange>:
{
    80000ac0:	7179                	add	sp,sp,-48
    80000ac2:	f406                	sd	ra,40(sp)
    80000ac4:	f022                	sd	s0,32(sp)
    80000ac6:	ec26                	sd	s1,24(sp)
    80000ac8:	1800                	add	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000aca:	6785                	lui	a5,0x1
    80000acc:	fff78713          	add	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad0:	00e504b3          	add	s1,a0,a4
    80000ad4:	777d                	lui	a4,0xfffff
    80000ad6:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad8:	94be                	add	s1,s1,a5
    80000ada:	0295e463          	bltu	a1,s1,80000b02 <freerange+0x42>
    80000ade:	e84a                	sd	s2,16(sp)
    80000ae0:	e44e                	sd	s3,8(sp)
    80000ae2:	e052                	sd	s4,0(sp)
    80000ae4:	892e                	mv	s2,a1
    kfree(p);
    80000ae6:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae8:	6985                	lui	s3,0x1
    kfree(p);
    80000aea:	01448533          	add	a0,s1,s4
    80000aee:	00000097          	auipc	ra,0x0
    80000af2:	f5c080e7          	jalr	-164(ra) # 80000a4a <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af6:	94ce                	add	s1,s1,s3
    80000af8:	fe9979e3          	bgeu	s2,s1,80000aea <freerange+0x2a>
    80000afc:	6942                	ld	s2,16(sp)
    80000afe:	69a2                	ld	s3,8(sp)
    80000b00:	6a02                	ld	s4,0(sp)
}
    80000b02:	70a2                	ld	ra,40(sp)
    80000b04:	7402                	ld	s0,32(sp)
    80000b06:	64e2                	ld	s1,24(sp)
    80000b08:	6145                	add	sp,sp,48
    80000b0a:	8082                	ret

0000000080000b0c <kinit>:
{
    80000b0c:	1141                	add	sp,sp,-16
    80000b0e:	e406                	sd	ra,8(sp)
    80000b10:	e022                	sd	s0,0(sp)
    80000b12:	0800                	add	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b14:	00007597          	auipc	a1,0x7
    80000b18:	54458593          	add	a1,a1,1348 # 80008058 <digits+0x28>
    80000b1c:	00013517          	auipc	a0,0x13
    80000b20:	9a450513          	add	a0,a0,-1628 # 800134c0 <kmem>
    80000b24:	00000097          	auipc	ra,0x0
    80000b28:	084080e7          	jalr	132(ra) # 80000ba8 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	sll	a1,a1,0x1b
    80000b30:	00024517          	auipc	a0,0x24
    80000b34:	1c050513          	add	a0,a0,448 # 80024cf0 <end>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	f88080e7          	jalr	-120(ra) # 80000ac0 <freerange>
}
    80000b40:	60a2                	ld	ra,8(sp)
    80000b42:	6402                	ld	s0,0(sp)
    80000b44:	0141                	add	sp,sp,16
    80000b46:	8082                	ret

0000000080000b48 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b48:	1101                	add	sp,sp,-32
    80000b4a:	ec06                	sd	ra,24(sp)
    80000b4c:	e822                	sd	s0,16(sp)
    80000b4e:	e426                	sd	s1,8(sp)
    80000b50:	1000                	add	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b52:	00013497          	auipc	s1,0x13
    80000b56:	96e48493          	add	s1,s1,-1682 # 800134c0 <kmem>
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	00000097          	auipc	ra,0x0
    80000b60:	0dc080e7          	jalr	220(ra) # 80000c38 <acquire>
  r = kmem.freelist;
    80000b64:	6c84                	ld	s1,24(s1)
  if(r)
    80000b66:	c885                	beqz	s1,80000b96 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b68:	609c                	ld	a5,0(s1)
    80000b6a:	00013517          	auipc	a0,0x13
    80000b6e:	95650513          	add	a0,a0,-1706 # 800134c0 <kmem>
    80000b72:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b74:	00000097          	auipc	ra,0x0
    80000b78:	178080e7          	jalr	376(ra) # 80000cec <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b7c:	6605                	lui	a2,0x1
    80000b7e:	4595                	li	a1,5
    80000b80:	8526                	mv	a0,s1
    80000b82:	00000097          	auipc	ra,0x0
    80000b86:	1b2080e7          	jalr	434(ra) # 80000d34 <memset>
  return (void*)r;
}
    80000b8a:	8526                	mv	a0,s1
    80000b8c:	60e2                	ld	ra,24(sp)
    80000b8e:	6442                	ld	s0,16(sp)
    80000b90:	64a2                	ld	s1,8(sp)
    80000b92:	6105                	add	sp,sp,32
    80000b94:	8082                	ret
  release(&kmem.lock);
    80000b96:	00013517          	auipc	a0,0x13
    80000b9a:	92a50513          	add	a0,a0,-1750 # 800134c0 <kmem>
    80000b9e:	00000097          	auipc	ra,0x0
    80000ba2:	14e080e7          	jalr	334(ra) # 80000cec <release>
  if(r)
    80000ba6:	b7d5                	j	80000b8a <kalloc+0x42>

0000000080000ba8 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000ba8:	1141                	add	sp,sp,-16
    80000baa:	e422                	sd	s0,8(sp)
    80000bac:	0800                	add	s0,sp,16
  lk->name = name;
    80000bae:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bb0:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bb4:	00053823          	sd	zero,16(a0)
}
    80000bb8:	6422                	ld	s0,8(sp)
    80000bba:	0141                	add	sp,sp,16
    80000bbc:	8082                	ret

0000000080000bbe <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bbe:	411c                	lw	a5,0(a0)
    80000bc0:	e399                	bnez	a5,80000bc6 <holding+0x8>
    80000bc2:	4501                	li	a0,0
  return r;
}
    80000bc4:	8082                	ret
{
    80000bc6:	1101                	add	sp,sp,-32
    80000bc8:	ec06                	sd	ra,24(sp)
    80000bca:	e822                	sd	s0,16(sp)
    80000bcc:	e426                	sd	s1,8(sp)
    80000bce:	1000                	add	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bd0:	6904                	ld	s1,16(a0)
    80000bd2:	00001097          	auipc	ra,0x1
    80000bd6:	e5c080e7          	jalr	-420(ra) # 80001a2e <mycpu>
    80000bda:	40a48533          	sub	a0,s1,a0
    80000bde:	00153513          	seqz	a0,a0
}
    80000be2:	60e2                	ld	ra,24(sp)
    80000be4:	6442                	ld	s0,16(sp)
    80000be6:	64a2                	ld	s1,8(sp)
    80000be8:	6105                	add	sp,sp,32
    80000bea:	8082                	ret

0000000080000bec <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bec:	1101                	add	sp,sp,-32
    80000bee:	ec06                	sd	ra,24(sp)
    80000bf0:	e822                	sd	s0,16(sp)
    80000bf2:	e426                	sd	s1,8(sp)
    80000bf4:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bf6:	100024f3          	csrr	s1,sstatus
    80000bfa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bfe:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c00:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c04:	00001097          	auipc	ra,0x1
    80000c08:	e2a080e7          	jalr	-470(ra) # 80001a2e <mycpu>
    80000c0c:	5d3c                	lw	a5,120(a0)
    80000c0e:	cf89                	beqz	a5,80000c28 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c10:	00001097          	auipc	ra,0x1
    80000c14:	e1e080e7          	jalr	-482(ra) # 80001a2e <mycpu>
    80000c18:	5d3c                	lw	a5,120(a0)
    80000c1a:	2785                	addw	a5,a5,1
    80000c1c:	dd3c                	sw	a5,120(a0)
}
    80000c1e:	60e2                	ld	ra,24(sp)
    80000c20:	6442                	ld	s0,16(sp)
    80000c22:	64a2                	ld	s1,8(sp)
    80000c24:	6105                	add	sp,sp,32
    80000c26:	8082                	ret
    mycpu()->intena = old;
    80000c28:	00001097          	auipc	ra,0x1
    80000c2c:	e06080e7          	jalr	-506(ra) # 80001a2e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c30:	8085                	srl	s1,s1,0x1
    80000c32:	8885                	and	s1,s1,1
    80000c34:	dd64                	sw	s1,124(a0)
    80000c36:	bfe9                	j	80000c10 <push_off+0x24>

0000000080000c38 <acquire>:
{
    80000c38:	1101                	add	sp,sp,-32
    80000c3a:	ec06                	sd	ra,24(sp)
    80000c3c:	e822                	sd	s0,16(sp)
    80000c3e:	e426                	sd	s1,8(sp)
    80000c40:	1000                	add	s0,sp,32
    80000c42:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c44:	00000097          	auipc	ra,0x0
    80000c48:	fa8080e7          	jalr	-88(ra) # 80000bec <push_off>
  if(holding(lk))
    80000c4c:	8526                	mv	a0,s1
    80000c4e:	00000097          	auipc	ra,0x0
    80000c52:	f70080e7          	jalr	-144(ra) # 80000bbe <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c56:	4705                	li	a4,1
  if(holding(lk))
    80000c58:	e115                	bnez	a0,80000c7c <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c5a:	87ba                	mv	a5,a4
    80000c5c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c60:	2781                	sext.w	a5,a5
    80000c62:	ffe5                	bnez	a5,80000c5a <acquire+0x22>
  __sync_synchronize();
    80000c64:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c68:	00001097          	auipc	ra,0x1
    80000c6c:	dc6080e7          	jalr	-570(ra) # 80001a2e <mycpu>
    80000c70:	e888                	sd	a0,16(s1)
}
    80000c72:	60e2                	ld	ra,24(sp)
    80000c74:	6442                	ld	s0,16(sp)
    80000c76:	64a2                	ld	s1,8(sp)
    80000c78:	6105                	add	sp,sp,32
    80000c7a:	8082                	ret
    panic("acquire");
    80000c7c:	00007517          	auipc	a0,0x7
    80000c80:	3e450513          	add	a0,a0,996 # 80008060 <digits+0x30>
    80000c84:	00000097          	auipc	ra,0x0
    80000c88:	8dc080e7          	jalr	-1828(ra) # 80000560 <panic>

0000000080000c8c <pop_off>:

void
pop_off(void)
{
    80000c8c:	1141                	add	sp,sp,-16
    80000c8e:	e406                	sd	ra,8(sp)
    80000c90:	e022                	sd	s0,0(sp)
    80000c92:	0800                	add	s0,sp,16
  struct cpu *c = mycpu();
    80000c94:	00001097          	auipc	ra,0x1
    80000c98:	d9a080e7          	jalr	-614(ra) # 80001a2e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c9c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000ca0:	8b89                	and	a5,a5,2
  if(intr_get())
    80000ca2:	e78d                	bnez	a5,80000ccc <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000ca4:	5d3c                	lw	a5,120(a0)
    80000ca6:	02f05b63          	blez	a5,80000cdc <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000caa:	37fd                	addw	a5,a5,-1
    80000cac:	0007871b          	sext.w	a4,a5
    80000cb0:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cb2:	eb09                	bnez	a4,80000cc4 <pop_off+0x38>
    80000cb4:	5d7c                	lw	a5,124(a0)
    80000cb6:	c799                	beqz	a5,80000cc4 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cb8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cbc:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cc0:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cc4:	60a2                	ld	ra,8(sp)
    80000cc6:	6402                	ld	s0,0(sp)
    80000cc8:	0141                	add	sp,sp,16
    80000cca:	8082                	ret
    panic("pop_off - interruptible");
    80000ccc:	00007517          	auipc	a0,0x7
    80000cd0:	39c50513          	add	a0,a0,924 # 80008068 <digits+0x38>
    80000cd4:	00000097          	auipc	ra,0x0
    80000cd8:	88c080e7          	jalr	-1908(ra) # 80000560 <panic>
    panic("pop_off");
    80000cdc:	00007517          	auipc	a0,0x7
    80000ce0:	3a450513          	add	a0,a0,932 # 80008080 <digits+0x50>
    80000ce4:	00000097          	auipc	ra,0x0
    80000ce8:	87c080e7          	jalr	-1924(ra) # 80000560 <panic>

0000000080000cec <release>:
{
    80000cec:	1101                	add	sp,sp,-32
    80000cee:	ec06                	sd	ra,24(sp)
    80000cf0:	e822                	sd	s0,16(sp)
    80000cf2:	e426                	sd	s1,8(sp)
    80000cf4:	1000                	add	s0,sp,32
    80000cf6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cf8:	00000097          	auipc	ra,0x0
    80000cfc:	ec6080e7          	jalr	-314(ra) # 80000bbe <holding>
    80000d00:	c115                	beqz	a0,80000d24 <release+0x38>
  lk->cpu = 0;
    80000d02:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d06:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d0a:	0f50000f          	fence	iorw,ow
    80000d0e:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d12:	00000097          	auipc	ra,0x0
    80000d16:	f7a080e7          	jalr	-134(ra) # 80000c8c <pop_off>
}
    80000d1a:	60e2                	ld	ra,24(sp)
    80000d1c:	6442                	ld	s0,16(sp)
    80000d1e:	64a2                	ld	s1,8(sp)
    80000d20:	6105                	add	sp,sp,32
    80000d22:	8082                	ret
    panic("release");
    80000d24:	00007517          	auipc	a0,0x7
    80000d28:	36450513          	add	a0,a0,868 # 80008088 <digits+0x58>
    80000d2c:	00000097          	auipc	ra,0x0
    80000d30:	834080e7          	jalr	-1996(ra) # 80000560 <panic>

0000000080000d34 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d34:	1141                	add	sp,sp,-16
    80000d36:	e422                	sd	s0,8(sp)
    80000d38:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d3a:	ca19                	beqz	a2,80000d50 <memset+0x1c>
    80000d3c:	87aa                	mv	a5,a0
    80000d3e:	1602                	sll	a2,a2,0x20
    80000d40:	9201                	srl	a2,a2,0x20
    80000d42:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d46:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d4a:	0785                	add	a5,a5,1
    80000d4c:	fee79de3          	bne	a5,a4,80000d46 <memset+0x12>
  }
  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	add	sp,sp,16
    80000d54:	8082                	ret

0000000080000d56 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d56:	1141                	add	sp,sp,-16
    80000d58:	e422                	sd	s0,8(sp)
    80000d5a:	0800                	add	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d5c:	ca05                	beqz	a2,80000d8c <memcmp+0x36>
    80000d5e:	fff6069b          	addw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d62:	1682                	sll	a3,a3,0x20
    80000d64:	9281                	srl	a3,a3,0x20
    80000d66:	0685                	add	a3,a3,1
    80000d68:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d6a:	00054783          	lbu	a5,0(a0)
    80000d6e:	0005c703          	lbu	a4,0(a1)
    80000d72:	00e79863          	bne	a5,a4,80000d82 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d76:	0505                	add	a0,a0,1
    80000d78:	0585                	add	a1,a1,1
  while(n-- > 0){
    80000d7a:	fed518e3          	bne	a0,a3,80000d6a <memcmp+0x14>
  }

  return 0;
    80000d7e:	4501                	li	a0,0
    80000d80:	a019                	j	80000d86 <memcmp+0x30>
      return *s1 - *s2;
    80000d82:	40e7853b          	subw	a0,a5,a4
}
    80000d86:	6422                	ld	s0,8(sp)
    80000d88:	0141                	add	sp,sp,16
    80000d8a:	8082                	ret
  return 0;
    80000d8c:	4501                	li	a0,0
    80000d8e:	bfe5                	j	80000d86 <memcmp+0x30>

0000000080000d90 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d90:	1141                	add	sp,sp,-16
    80000d92:	e422                	sd	s0,8(sp)
    80000d94:	0800                	add	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d96:	c205                	beqz	a2,80000db6 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d98:	02a5e263          	bltu	a1,a0,80000dbc <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d9c:	1602                	sll	a2,a2,0x20
    80000d9e:	9201                	srl	a2,a2,0x20
    80000da0:	00c587b3          	add	a5,a1,a2
{
    80000da4:	872a                	mv	a4,a0
      *d++ = *s++;
    80000da6:	0585                	add	a1,a1,1
    80000da8:	0705                	add	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffda311>
    80000daa:	fff5c683          	lbu	a3,-1(a1)
    80000dae:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000db2:	feb79ae3          	bne	a5,a1,80000da6 <memmove+0x16>

  return dst;
}
    80000db6:	6422                	ld	s0,8(sp)
    80000db8:	0141                	add	sp,sp,16
    80000dba:	8082                	ret
  if(s < d && s + n > d){
    80000dbc:	02061693          	sll	a3,a2,0x20
    80000dc0:	9281                	srl	a3,a3,0x20
    80000dc2:	00d58733          	add	a4,a1,a3
    80000dc6:	fce57be3          	bgeu	a0,a4,80000d9c <memmove+0xc>
    d += n;
    80000dca:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000dcc:	fff6079b          	addw	a5,a2,-1
    80000dd0:	1782                	sll	a5,a5,0x20
    80000dd2:	9381                	srl	a5,a5,0x20
    80000dd4:	fff7c793          	not	a5,a5
    80000dd8:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000dda:	177d                	add	a4,a4,-1
    80000ddc:	16fd                	add	a3,a3,-1
    80000dde:	00074603          	lbu	a2,0(a4)
    80000de2:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000de6:	fef71ae3          	bne	a4,a5,80000dda <memmove+0x4a>
    80000dea:	b7f1                	j	80000db6 <memmove+0x26>

0000000080000dec <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dec:	1141                	add	sp,sp,-16
    80000dee:	e406                	sd	ra,8(sp)
    80000df0:	e022                	sd	s0,0(sp)
    80000df2:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
    80000df4:	00000097          	auipc	ra,0x0
    80000df8:	f9c080e7          	jalr	-100(ra) # 80000d90 <memmove>
}
    80000dfc:	60a2                	ld	ra,8(sp)
    80000dfe:	6402                	ld	s0,0(sp)
    80000e00:	0141                	add	sp,sp,16
    80000e02:	8082                	ret

0000000080000e04 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e04:	1141                	add	sp,sp,-16
    80000e06:	e422                	sd	s0,8(sp)
    80000e08:	0800                	add	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e0a:	ce11                	beqz	a2,80000e26 <strncmp+0x22>
    80000e0c:	00054783          	lbu	a5,0(a0)
    80000e10:	cf89                	beqz	a5,80000e2a <strncmp+0x26>
    80000e12:	0005c703          	lbu	a4,0(a1)
    80000e16:	00f71a63          	bne	a4,a5,80000e2a <strncmp+0x26>
    n--, p++, q++;
    80000e1a:	367d                	addw	a2,a2,-1
    80000e1c:	0505                	add	a0,a0,1
    80000e1e:	0585                	add	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e20:	f675                	bnez	a2,80000e0c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e22:	4501                	li	a0,0
    80000e24:	a801                	j	80000e34 <strncmp+0x30>
    80000e26:	4501                	li	a0,0
    80000e28:	a031                	j	80000e34 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000e2a:	00054503          	lbu	a0,0(a0)
    80000e2e:	0005c783          	lbu	a5,0(a1)
    80000e32:	9d1d                	subw	a0,a0,a5
}
    80000e34:	6422                	ld	s0,8(sp)
    80000e36:	0141                	add	sp,sp,16
    80000e38:	8082                	ret

0000000080000e3a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e3a:	1141                	add	sp,sp,-16
    80000e3c:	e422                	sd	s0,8(sp)
    80000e3e:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e40:	87aa                	mv	a5,a0
    80000e42:	86b2                	mv	a3,a2
    80000e44:	367d                	addw	a2,a2,-1
    80000e46:	02d05563          	blez	a3,80000e70 <strncpy+0x36>
    80000e4a:	0785                	add	a5,a5,1
    80000e4c:	0005c703          	lbu	a4,0(a1)
    80000e50:	fee78fa3          	sb	a4,-1(a5)
    80000e54:	0585                	add	a1,a1,1
    80000e56:	f775                	bnez	a4,80000e42 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e58:	873e                	mv	a4,a5
    80000e5a:	9fb5                	addw	a5,a5,a3
    80000e5c:	37fd                	addw	a5,a5,-1
    80000e5e:	00c05963          	blez	a2,80000e70 <strncpy+0x36>
    *s++ = 0;
    80000e62:	0705                	add	a4,a4,1
    80000e64:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e68:	40e786bb          	subw	a3,a5,a4
    80000e6c:	fed04be3          	bgtz	a3,80000e62 <strncpy+0x28>
  return os;
}
    80000e70:	6422                	ld	s0,8(sp)
    80000e72:	0141                	add	sp,sp,16
    80000e74:	8082                	ret

0000000080000e76 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e76:	1141                	add	sp,sp,-16
    80000e78:	e422                	sd	s0,8(sp)
    80000e7a:	0800                	add	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e7c:	02c05363          	blez	a2,80000ea2 <safestrcpy+0x2c>
    80000e80:	fff6069b          	addw	a3,a2,-1
    80000e84:	1682                	sll	a3,a3,0x20
    80000e86:	9281                	srl	a3,a3,0x20
    80000e88:	96ae                	add	a3,a3,a1
    80000e8a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e8c:	00d58963          	beq	a1,a3,80000e9e <safestrcpy+0x28>
    80000e90:	0585                	add	a1,a1,1
    80000e92:	0785                	add	a5,a5,1
    80000e94:	fff5c703          	lbu	a4,-1(a1)
    80000e98:	fee78fa3          	sb	a4,-1(a5)
    80000e9c:	fb65                	bnez	a4,80000e8c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e9e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ea2:	6422                	ld	s0,8(sp)
    80000ea4:	0141                	add	sp,sp,16
    80000ea6:	8082                	ret

0000000080000ea8 <strlen>:

int
strlen(const char *s)
{
    80000ea8:	1141                	add	sp,sp,-16
    80000eaa:	e422                	sd	s0,8(sp)
    80000eac:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000eae:	00054783          	lbu	a5,0(a0)
    80000eb2:	cf91                	beqz	a5,80000ece <strlen+0x26>
    80000eb4:	0505                	add	a0,a0,1
    80000eb6:	87aa                	mv	a5,a0
    80000eb8:	86be                	mv	a3,a5
    80000eba:	0785                	add	a5,a5,1
    80000ebc:	fff7c703          	lbu	a4,-1(a5)
    80000ec0:	ff65                	bnez	a4,80000eb8 <strlen+0x10>
    80000ec2:	40a6853b          	subw	a0,a3,a0
    80000ec6:	2505                	addw	a0,a0,1
    ;
  return n;
}
    80000ec8:	6422                	ld	s0,8(sp)
    80000eca:	0141                	add	sp,sp,16
    80000ecc:	8082                	ret
  for(n = 0; s[n]; n++)
    80000ece:	4501                	li	a0,0
    80000ed0:	bfe5                	j	80000ec8 <strlen+0x20>

0000000080000ed2 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ed2:	1141                	add	sp,sp,-16
    80000ed4:	e406                	sd	ra,8(sp)
    80000ed6:	e022                	sd	s0,0(sp)
    80000ed8:	0800                	add	s0,sp,16
  if(cpuid() == 0){
    80000eda:	00001097          	auipc	ra,0x1
    80000ede:	b44080e7          	jalr	-1212(ra) # 80001a1e <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ee2:	0000a717          	auipc	a4,0xa
    80000ee6:	37670713          	add	a4,a4,886 # 8000b258 <started>
  if(cpuid() == 0){
    80000eea:	c139                	beqz	a0,80000f30 <main+0x5e>
    while(started == 0)
    80000eec:	431c                	lw	a5,0(a4)
    80000eee:	2781                	sext.w	a5,a5
    80000ef0:	dff5                	beqz	a5,80000eec <main+0x1a>
      ;
    __sync_synchronize();
    80000ef2:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000ef6:	00001097          	auipc	ra,0x1
    80000efa:	b28080e7          	jalr	-1240(ra) # 80001a1e <cpuid>
    80000efe:	85aa                	mv	a1,a0
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	1a850513          	add	a0,a0,424 # 800080a8 <digits+0x78>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	6a2080e7          	jalr	1698(ra) # 800005aa <printf>
    kvminithart();    // turn on paging
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	0d8080e7          	jalr	216(ra) # 80000fe8 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f18:	00001097          	auipc	ra,0x1
    80000f1c:	7e4080e7          	jalr	2020(ra) # 800026fc <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f20:	00005097          	auipc	ra,0x5
    80000f24:	084080e7          	jalr	132(ra) # 80005fa4 <plicinithart>
  }

  scheduler();        
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	01a080e7          	jalr	26(ra) # 80001f42 <scheduler>
    consoleinit();
    80000f30:	fffff097          	auipc	ra,0xfffff
    80000f34:	540080e7          	jalr	1344(ra) # 80000470 <consoleinit>
    printfinit();
    80000f38:	00000097          	auipc	ra,0x0
    80000f3c:	87a080e7          	jalr	-1926(ra) # 800007b2 <printfinit>
    printf("\n");
    80000f40:	00007517          	auipc	a0,0x7
    80000f44:	17850513          	add	a0,a0,376 # 800080b8 <digits+0x88>
    80000f48:	fffff097          	auipc	ra,0xfffff
    80000f4c:	662080e7          	jalr	1634(ra) # 800005aa <printf>
    printf("xv6 kernel is booting\n");
    80000f50:	00007517          	auipc	a0,0x7
    80000f54:	14050513          	add	a0,a0,320 # 80008090 <digits+0x60>
    80000f58:	fffff097          	auipc	ra,0xfffff
    80000f5c:	652080e7          	jalr	1618(ra) # 800005aa <printf>
    printf("\n");
    80000f60:	00007517          	auipc	a0,0x7
    80000f64:	15850513          	add	a0,a0,344 # 800080b8 <digits+0x88>
    80000f68:	fffff097          	auipc	ra,0xfffff
    80000f6c:	642080e7          	jalr	1602(ra) # 800005aa <printf>
    kinit();         // physical page allocator
    80000f70:	00000097          	auipc	ra,0x0
    80000f74:	b9c080e7          	jalr	-1124(ra) # 80000b0c <kinit>
    kvminit();       // create kernel page table
    80000f78:	00000097          	auipc	ra,0x0
    80000f7c:	326080e7          	jalr	806(ra) # 8000129e <kvminit>
    kvminithart();   // turn on paging
    80000f80:	00000097          	auipc	ra,0x0
    80000f84:	068080e7          	jalr	104(ra) # 80000fe8 <kvminithart>
    procinit();      // process table
    80000f88:	00001097          	auipc	ra,0x1
    80000f8c:	9d4080e7          	jalr	-1580(ra) # 8000195c <procinit>
    trapinit();      // trap vectors
    80000f90:	00001097          	auipc	ra,0x1
    80000f94:	744080e7          	jalr	1860(ra) # 800026d4 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f98:	00001097          	auipc	ra,0x1
    80000f9c:	764080e7          	jalr	1892(ra) # 800026fc <trapinithart>
    plicinit();      // set up interrupt controller
    80000fa0:	00005097          	auipc	ra,0x5
    80000fa4:	fea080e7          	jalr	-22(ra) # 80005f8a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa8:	00005097          	auipc	ra,0x5
    80000fac:	ffc080e7          	jalr	-4(ra) # 80005fa4 <plicinithart>
    binit();         // buffer cache
    80000fb0:	00002097          	auipc	ra,0x2
    80000fb4:	0bc080e7          	jalr	188(ra) # 8000306c <binit>
    iinit();         // inode table
    80000fb8:	00002097          	auipc	ra,0x2
    80000fbc:	772080e7          	jalr	1906(ra) # 8000372a <iinit>
    fileinit();      // file table
    80000fc0:	00003097          	auipc	ra,0x3
    80000fc4:	722080e7          	jalr	1826(ra) # 800046e2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fc8:	00005097          	auipc	ra,0x5
    80000fcc:	0e4080e7          	jalr	228(ra) # 800060ac <virtio_disk_init>
    userinit();      // first user process
    80000fd0:	00001097          	auipc	ra,0x1
    80000fd4:	d52080e7          	jalr	-686(ra) # 80001d22 <userinit>
    __sync_synchronize();
    80000fd8:	0ff0000f          	fence
    started = 1;
    80000fdc:	4785                	li	a5,1
    80000fde:	0000a717          	auipc	a4,0xa
    80000fe2:	26f72d23          	sw	a5,634(a4) # 8000b258 <started>
    80000fe6:	b789                	j	80000f28 <main+0x56>

0000000080000fe8 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fe8:	1141                	add	sp,sp,-16
    80000fea:	e422                	sd	s0,8(sp)
    80000fec:	0800                	add	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fee:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ff2:	0000a797          	auipc	a5,0xa
    80000ff6:	26e7b783          	ld	a5,622(a5) # 8000b260 <kernel_pagetable>
    80000ffa:	83b1                	srl	a5,a5,0xc
    80000ffc:	577d                	li	a4,-1
    80000ffe:	177e                	sll	a4,a4,0x3f
    80001000:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001002:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001006:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    8000100a:	6422                	ld	s0,8(sp)
    8000100c:	0141                	add	sp,sp,16
    8000100e:	8082                	ret

0000000080001010 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001010:	7139                	add	sp,sp,-64
    80001012:	fc06                	sd	ra,56(sp)
    80001014:	f822                	sd	s0,48(sp)
    80001016:	f426                	sd	s1,40(sp)
    80001018:	f04a                	sd	s2,32(sp)
    8000101a:	ec4e                	sd	s3,24(sp)
    8000101c:	e852                	sd	s4,16(sp)
    8000101e:	e456                	sd	s5,8(sp)
    80001020:	e05a                	sd	s6,0(sp)
    80001022:	0080                	add	s0,sp,64
    80001024:	84aa                	mv	s1,a0
    80001026:	89ae                	mv	s3,a1
    80001028:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000102a:	57fd                	li	a5,-1
    8000102c:	83e9                	srl	a5,a5,0x1a
    8000102e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001030:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001032:	04b7f263          	bgeu	a5,a1,80001076 <walk+0x66>
    panic("walk");
    80001036:	00007517          	auipc	a0,0x7
    8000103a:	08a50513          	add	a0,a0,138 # 800080c0 <digits+0x90>
    8000103e:	fffff097          	auipc	ra,0xfffff
    80001042:	522080e7          	jalr	1314(ra) # 80000560 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001046:	060a8663          	beqz	s5,800010b2 <walk+0xa2>
    8000104a:	00000097          	auipc	ra,0x0
    8000104e:	afe080e7          	jalr	-1282(ra) # 80000b48 <kalloc>
    80001052:	84aa                	mv	s1,a0
    80001054:	c529                	beqz	a0,8000109e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001056:	6605                	lui	a2,0x1
    80001058:	4581                	li	a1,0
    8000105a:	00000097          	auipc	ra,0x0
    8000105e:	cda080e7          	jalr	-806(ra) # 80000d34 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001062:	00c4d793          	srl	a5,s1,0xc
    80001066:	07aa                	sll	a5,a5,0xa
    80001068:	0017e793          	or	a5,a5,1
    8000106c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001070:	3a5d                	addw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffda307>
    80001072:	036a0063          	beq	s4,s6,80001092 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001076:	0149d933          	srl	s2,s3,s4
    8000107a:	1ff97913          	and	s2,s2,511
    8000107e:	090e                	sll	s2,s2,0x3
    80001080:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001082:	00093483          	ld	s1,0(s2)
    80001086:	0014f793          	and	a5,s1,1
    8000108a:	dfd5                	beqz	a5,80001046 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000108c:	80a9                	srl	s1,s1,0xa
    8000108e:	04b2                	sll	s1,s1,0xc
    80001090:	b7c5                	j	80001070 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001092:	00c9d513          	srl	a0,s3,0xc
    80001096:	1ff57513          	and	a0,a0,511
    8000109a:	050e                	sll	a0,a0,0x3
    8000109c:	9526                	add	a0,a0,s1
}
    8000109e:	70e2                	ld	ra,56(sp)
    800010a0:	7442                	ld	s0,48(sp)
    800010a2:	74a2                	ld	s1,40(sp)
    800010a4:	7902                	ld	s2,32(sp)
    800010a6:	69e2                	ld	s3,24(sp)
    800010a8:	6a42                	ld	s4,16(sp)
    800010aa:	6aa2                	ld	s5,8(sp)
    800010ac:	6b02                	ld	s6,0(sp)
    800010ae:	6121                	add	sp,sp,64
    800010b0:	8082                	ret
        return 0;
    800010b2:	4501                	li	a0,0
    800010b4:	b7ed                	j	8000109e <walk+0x8e>

00000000800010b6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010b6:	57fd                	li	a5,-1
    800010b8:	83e9                	srl	a5,a5,0x1a
    800010ba:	00b7f463          	bgeu	a5,a1,800010c2 <walkaddr+0xc>
    return 0;
    800010be:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010c0:	8082                	ret
{
    800010c2:	1141                	add	sp,sp,-16
    800010c4:	e406                	sd	ra,8(sp)
    800010c6:	e022                	sd	s0,0(sp)
    800010c8:	0800                	add	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010ca:	4601                	li	a2,0
    800010cc:	00000097          	auipc	ra,0x0
    800010d0:	f44080e7          	jalr	-188(ra) # 80001010 <walk>
  if(pte == 0)
    800010d4:	c105                	beqz	a0,800010f4 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010d6:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010d8:	0117f693          	and	a3,a5,17
    800010dc:	4745                	li	a4,17
    return 0;
    800010de:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010e0:	00e68663          	beq	a3,a4,800010ec <walkaddr+0x36>
}
    800010e4:	60a2                	ld	ra,8(sp)
    800010e6:	6402                	ld	s0,0(sp)
    800010e8:	0141                	add	sp,sp,16
    800010ea:	8082                	ret
  pa = PTE2PA(*pte);
    800010ec:	83a9                	srl	a5,a5,0xa
    800010ee:	00c79513          	sll	a0,a5,0xc
  return pa;
    800010f2:	bfcd                	j	800010e4 <walkaddr+0x2e>
    return 0;
    800010f4:	4501                	li	a0,0
    800010f6:	b7fd                	j	800010e4 <walkaddr+0x2e>

00000000800010f8 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010f8:	715d                	add	sp,sp,-80
    800010fa:	e486                	sd	ra,72(sp)
    800010fc:	e0a2                	sd	s0,64(sp)
    800010fe:	fc26                	sd	s1,56(sp)
    80001100:	f84a                	sd	s2,48(sp)
    80001102:	f44e                	sd	s3,40(sp)
    80001104:	f052                	sd	s4,32(sp)
    80001106:	ec56                	sd	s5,24(sp)
    80001108:	e85a                	sd	s6,16(sp)
    8000110a:	e45e                	sd	s7,8(sp)
    8000110c:	0880                	add	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    8000110e:	c639                	beqz	a2,8000115c <mappages+0x64>
    80001110:	8aaa                	mv	s5,a0
    80001112:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001114:	777d                	lui	a4,0xfffff
    80001116:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000111a:	fff58993          	add	s3,a1,-1
    8000111e:	99b2                	add	s3,s3,a2
    80001120:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001124:	893e                	mv	s2,a5
    80001126:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000112a:	6b85                	lui	s7,0x1
    8000112c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001130:	4605                	li	a2,1
    80001132:	85ca                	mv	a1,s2
    80001134:	8556                	mv	a0,s5
    80001136:	00000097          	auipc	ra,0x0
    8000113a:	eda080e7          	jalr	-294(ra) # 80001010 <walk>
    8000113e:	cd1d                	beqz	a0,8000117c <mappages+0x84>
    if(*pte & PTE_V)
    80001140:	611c                	ld	a5,0(a0)
    80001142:	8b85                	and	a5,a5,1
    80001144:	e785                	bnez	a5,8000116c <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001146:	80b1                	srl	s1,s1,0xc
    80001148:	04aa                	sll	s1,s1,0xa
    8000114a:	0164e4b3          	or	s1,s1,s6
    8000114e:	0014e493          	or	s1,s1,1
    80001152:	e104                	sd	s1,0(a0)
    if(a == last)
    80001154:	05390063          	beq	s2,s3,80001194 <mappages+0x9c>
    a += PGSIZE;
    80001158:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000115a:	bfc9                	j	8000112c <mappages+0x34>
    panic("mappages: size");
    8000115c:	00007517          	auipc	a0,0x7
    80001160:	f6c50513          	add	a0,a0,-148 # 800080c8 <digits+0x98>
    80001164:	fffff097          	auipc	ra,0xfffff
    80001168:	3fc080e7          	jalr	1020(ra) # 80000560 <panic>
      panic("mappages: remap");
    8000116c:	00007517          	auipc	a0,0x7
    80001170:	f6c50513          	add	a0,a0,-148 # 800080d8 <digits+0xa8>
    80001174:	fffff097          	auipc	ra,0xfffff
    80001178:	3ec080e7          	jalr	1004(ra) # 80000560 <panic>
      return -1;
    8000117c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000117e:	60a6                	ld	ra,72(sp)
    80001180:	6406                	ld	s0,64(sp)
    80001182:	74e2                	ld	s1,56(sp)
    80001184:	7942                	ld	s2,48(sp)
    80001186:	79a2                	ld	s3,40(sp)
    80001188:	7a02                	ld	s4,32(sp)
    8000118a:	6ae2                	ld	s5,24(sp)
    8000118c:	6b42                	ld	s6,16(sp)
    8000118e:	6ba2                	ld	s7,8(sp)
    80001190:	6161                	add	sp,sp,80
    80001192:	8082                	ret
  return 0;
    80001194:	4501                	li	a0,0
    80001196:	b7e5                	j	8000117e <mappages+0x86>

0000000080001198 <kvmmap>:
{
    80001198:	1141                	add	sp,sp,-16
    8000119a:	e406                	sd	ra,8(sp)
    8000119c:	e022                	sd	s0,0(sp)
    8000119e:	0800                	add	s0,sp,16
    800011a0:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011a2:	86b2                	mv	a3,a2
    800011a4:	863e                	mv	a2,a5
    800011a6:	00000097          	auipc	ra,0x0
    800011aa:	f52080e7          	jalr	-174(ra) # 800010f8 <mappages>
    800011ae:	e509                	bnez	a0,800011b8 <kvmmap+0x20>
}
    800011b0:	60a2                	ld	ra,8(sp)
    800011b2:	6402                	ld	s0,0(sp)
    800011b4:	0141                	add	sp,sp,16
    800011b6:	8082                	ret
    panic("kvmmap");
    800011b8:	00007517          	auipc	a0,0x7
    800011bc:	f3050513          	add	a0,a0,-208 # 800080e8 <digits+0xb8>
    800011c0:	fffff097          	auipc	ra,0xfffff
    800011c4:	3a0080e7          	jalr	928(ra) # 80000560 <panic>

00000000800011c8 <kvmmake>:
{
    800011c8:	1101                	add	sp,sp,-32
    800011ca:	ec06                	sd	ra,24(sp)
    800011cc:	e822                	sd	s0,16(sp)
    800011ce:	e426                	sd	s1,8(sp)
    800011d0:	e04a                	sd	s2,0(sp)
    800011d2:	1000                	add	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011d4:	00000097          	auipc	ra,0x0
    800011d8:	974080e7          	jalr	-1676(ra) # 80000b48 <kalloc>
    800011dc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011de:	6605                	lui	a2,0x1
    800011e0:	4581                	li	a1,0
    800011e2:	00000097          	auipc	ra,0x0
    800011e6:	b52080e7          	jalr	-1198(ra) # 80000d34 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011ea:	4719                	li	a4,6
    800011ec:	6685                	lui	a3,0x1
    800011ee:	10000637          	lui	a2,0x10000
    800011f2:	100005b7          	lui	a1,0x10000
    800011f6:	8526                	mv	a0,s1
    800011f8:	00000097          	auipc	ra,0x0
    800011fc:	fa0080e7          	jalr	-96(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001200:	4719                	li	a4,6
    80001202:	6685                	lui	a3,0x1
    80001204:	10001637          	lui	a2,0x10001
    80001208:	100015b7          	lui	a1,0x10001
    8000120c:	8526                	mv	a0,s1
    8000120e:	00000097          	auipc	ra,0x0
    80001212:	f8a080e7          	jalr	-118(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001216:	4719                	li	a4,6
    80001218:	004006b7          	lui	a3,0x400
    8000121c:	0c000637          	lui	a2,0xc000
    80001220:	0c0005b7          	lui	a1,0xc000
    80001224:	8526                	mv	a0,s1
    80001226:	00000097          	auipc	ra,0x0
    8000122a:	f72080e7          	jalr	-142(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000122e:	00007917          	auipc	s2,0x7
    80001232:	dd290913          	add	s2,s2,-558 # 80008000 <etext>
    80001236:	4729                	li	a4,10
    80001238:	80007697          	auipc	a3,0x80007
    8000123c:	dc868693          	add	a3,a3,-568 # 8000 <_entry-0x7fff8000>
    80001240:	4605                	li	a2,1
    80001242:	067e                	sll	a2,a2,0x1f
    80001244:	85b2                	mv	a1,a2
    80001246:	8526                	mv	a0,s1
    80001248:	00000097          	auipc	ra,0x0
    8000124c:	f50080e7          	jalr	-176(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001250:	46c5                	li	a3,17
    80001252:	06ee                	sll	a3,a3,0x1b
    80001254:	4719                	li	a4,6
    80001256:	412686b3          	sub	a3,a3,s2
    8000125a:	864a                	mv	a2,s2
    8000125c:	85ca                	mv	a1,s2
    8000125e:	8526                	mv	a0,s1
    80001260:	00000097          	auipc	ra,0x0
    80001264:	f38080e7          	jalr	-200(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001268:	4729                	li	a4,10
    8000126a:	6685                	lui	a3,0x1
    8000126c:	00006617          	auipc	a2,0x6
    80001270:	d9460613          	add	a2,a2,-620 # 80007000 <_trampoline>
    80001274:	040005b7          	lui	a1,0x4000
    80001278:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000127a:	05b2                	sll	a1,a1,0xc
    8000127c:	8526                	mv	a0,s1
    8000127e:	00000097          	auipc	ra,0x0
    80001282:	f1a080e7          	jalr	-230(ra) # 80001198 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001286:	8526                	mv	a0,s1
    80001288:	00000097          	auipc	ra,0x0
    8000128c:	630080e7          	jalr	1584(ra) # 800018b8 <proc_mapstacks>
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6902                	ld	s2,0(sp)
    8000129a:	6105                	add	sp,sp,32
    8000129c:	8082                	ret

000000008000129e <kvminit>:
{
    8000129e:	1141                	add	sp,sp,-16
    800012a0:	e406                	sd	ra,8(sp)
    800012a2:	e022                	sd	s0,0(sp)
    800012a4:	0800                	add	s0,sp,16
  kernel_pagetable = kvmmake();
    800012a6:	00000097          	auipc	ra,0x0
    800012aa:	f22080e7          	jalr	-222(ra) # 800011c8 <kvmmake>
    800012ae:	0000a797          	auipc	a5,0xa
    800012b2:	faa7b923          	sd	a0,-78(a5) # 8000b260 <kernel_pagetable>
}
    800012b6:	60a2                	ld	ra,8(sp)
    800012b8:	6402                	ld	s0,0(sp)
    800012ba:	0141                	add	sp,sp,16
    800012bc:	8082                	ret

00000000800012be <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012be:	715d                	add	sp,sp,-80
    800012c0:	e486                	sd	ra,72(sp)
    800012c2:	e0a2                	sd	s0,64(sp)
    800012c4:	0880                	add	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012c6:	03459793          	sll	a5,a1,0x34
    800012ca:	e39d                	bnez	a5,800012f0 <uvmunmap+0x32>
    800012cc:	f84a                	sd	s2,48(sp)
    800012ce:	f44e                	sd	s3,40(sp)
    800012d0:	f052                	sd	s4,32(sp)
    800012d2:	ec56                	sd	s5,24(sp)
    800012d4:	e85a                	sd	s6,16(sp)
    800012d6:	e45e                	sd	s7,8(sp)
    800012d8:	8a2a                	mv	s4,a0
    800012da:	892e                	mv	s2,a1
    800012dc:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012de:	0632                	sll	a2,a2,0xc
    800012e0:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012e4:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e6:	6b05                	lui	s6,0x1
    800012e8:	0935fb63          	bgeu	a1,s3,8000137e <uvmunmap+0xc0>
    800012ec:	fc26                	sd	s1,56(sp)
    800012ee:	a8a9                	j	80001348 <uvmunmap+0x8a>
    800012f0:	fc26                	sd	s1,56(sp)
    800012f2:	f84a                	sd	s2,48(sp)
    800012f4:	f44e                	sd	s3,40(sp)
    800012f6:	f052                	sd	s4,32(sp)
    800012f8:	ec56                	sd	s5,24(sp)
    800012fa:	e85a                	sd	s6,16(sp)
    800012fc:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800012fe:	00007517          	auipc	a0,0x7
    80001302:	df250513          	add	a0,a0,-526 # 800080f0 <digits+0xc0>
    80001306:	fffff097          	auipc	ra,0xfffff
    8000130a:	25a080e7          	jalr	602(ra) # 80000560 <panic>
      panic("uvmunmap: walk");
    8000130e:	00007517          	auipc	a0,0x7
    80001312:	dfa50513          	add	a0,a0,-518 # 80008108 <digits+0xd8>
    80001316:	fffff097          	auipc	ra,0xfffff
    8000131a:	24a080e7          	jalr	586(ra) # 80000560 <panic>
      panic("uvmunmap: not mapped");
    8000131e:	00007517          	auipc	a0,0x7
    80001322:	dfa50513          	add	a0,a0,-518 # 80008118 <digits+0xe8>
    80001326:	fffff097          	auipc	ra,0xfffff
    8000132a:	23a080e7          	jalr	570(ra) # 80000560 <panic>
      panic("uvmunmap: not a leaf");
    8000132e:	00007517          	auipc	a0,0x7
    80001332:	e0250513          	add	a0,a0,-510 # 80008130 <digits+0x100>
    80001336:	fffff097          	auipc	ra,0xfffff
    8000133a:	22a080e7          	jalr	554(ra) # 80000560 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000133e:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001342:	995a                	add	s2,s2,s6
    80001344:	03397c63          	bgeu	s2,s3,8000137c <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001348:	4601                	li	a2,0
    8000134a:	85ca                	mv	a1,s2
    8000134c:	8552                	mv	a0,s4
    8000134e:	00000097          	auipc	ra,0x0
    80001352:	cc2080e7          	jalr	-830(ra) # 80001010 <walk>
    80001356:	84aa                	mv	s1,a0
    80001358:	d95d                	beqz	a0,8000130e <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    8000135a:	6108                	ld	a0,0(a0)
    8000135c:	00157793          	and	a5,a0,1
    80001360:	dfdd                	beqz	a5,8000131e <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001362:	3ff57793          	and	a5,a0,1023
    80001366:	fd7784e3          	beq	a5,s7,8000132e <uvmunmap+0x70>
    if(do_free){
    8000136a:	fc0a8ae3          	beqz	s5,8000133e <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    8000136e:	8129                	srl	a0,a0,0xa
      kfree((void*)pa);
    80001370:	0532                	sll	a0,a0,0xc
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	6d8080e7          	jalr	1752(ra) # 80000a4a <kfree>
    8000137a:	b7d1                	j	8000133e <uvmunmap+0x80>
    8000137c:	74e2                	ld	s1,56(sp)
    8000137e:	7942                	ld	s2,48(sp)
    80001380:	79a2                	ld	s3,40(sp)
    80001382:	7a02                	ld	s4,32(sp)
    80001384:	6ae2                	ld	s5,24(sp)
    80001386:	6b42                	ld	s6,16(sp)
    80001388:	6ba2                	ld	s7,8(sp)
  }
}
    8000138a:	60a6                	ld	ra,72(sp)
    8000138c:	6406                	ld	s0,64(sp)
    8000138e:	6161                	add	sp,sp,80
    80001390:	8082                	ret

0000000080001392 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001392:	1101                	add	sp,sp,-32
    80001394:	ec06                	sd	ra,24(sp)
    80001396:	e822                	sd	s0,16(sp)
    80001398:	e426                	sd	s1,8(sp)
    8000139a:	1000                	add	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000139c:	fffff097          	auipc	ra,0xfffff
    800013a0:	7ac080e7          	jalr	1964(ra) # 80000b48 <kalloc>
    800013a4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013a6:	c519                	beqz	a0,800013b4 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013a8:	6605                	lui	a2,0x1
    800013aa:	4581                	li	a1,0
    800013ac:	00000097          	auipc	ra,0x0
    800013b0:	988080e7          	jalr	-1656(ra) # 80000d34 <memset>
  return pagetable;
}
    800013b4:	8526                	mv	a0,s1
    800013b6:	60e2                	ld	ra,24(sp)
    800013b8:	6442                	ld	s0,16(sp)
    800013ba:	64a2                	ld	s1,8(sp)
    800013bc:	6105                	add	sp,sp,32
    800013be:	8082                	ret

00000000800013c0 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800013c0:	7179                	add	sp,sp,-48
    800013c2:	f406                	sd	ra,40(sp)
    800013c4:	f022                	sd	s0,32(sp)
    800013c6:	ec26                	sd	s1,24(sp)
    800013c8:	e84a                	sd	s2,16(sp)
    800013ca:	e44e                	sd	s3,8(sp)
    800013cc:	e052                	sd	s4,0(sp)
    800013ce:	1800                	add	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013d0:	6785                	lui	a5,0x1
    800013d2:	04f67863          	bgeu	a2,a5,80001422 <uvmfirst+0x62>
    800013d6:	8a2a                	mv	s4,a0
    800013d8:	89ae                	mv	s3,a1
    800013da:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800013dc:	fffff097          	auipc	ra,0xfffff
    800013e0:	76c080e7          	jalr	1900(ra) # 80000b48 <kalloc>
    800013e4:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013e6:	6605                	lui	a2,0x1
    800013e8:	4581                	li	a1,0
    800013ea:	00000097          	auipc	ra,0x0
    800013ee:	94a080e7          	jalr	-1718(ra) # 80000d34 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013f2:	4779                	li	a4,30
    800013f4:	86ca                	mv	a3,s2
    800013f6:	6605                	lui	a2,0x1
    800013f8:	4581                	li	a1,0
    800013fa:	8552                	mv	a0,s4
    800013fc:	00000097          	auipc	ra,0x0
    80001400:	cfc080e7          	jalr	-772(ra) # 800010f8 <mappages>
  memmove(mem, src, sz);
    80001404:	8626                	mv	a2,s1
    80001406:	85ce                	mv	a1,s3
    80001408:	854a                	mv	a0,s2
    8000140a:	00000097          	auipc	ra,0x0
    8000140e:	986080e7          	jalr	-1658(ra) # 80000d90 <memmove>
}
    80001412:	70a2                	ld	ra,40(sp)
    80001414:	7402                	ld	s0,32(sp)
    80001416:	64e2                	ld	s1,24(sp)
    80001418:	6942                	ld	s2,16(sp)
    8000141a:	69a2                	ld	s3,8(sp)
    8000141c:	6a02                	ld	s4,0(sp)
    8000141e:	6145                	add	sp,sp,48
    80001420:	8082                	ret
    panic("uvmfirst: more than a page");
    80001422:	00007517          	auipc	a0,0x7
    80001426:	d2650513          	add	a0,a0,-730 # 80008148 <digits+0x118>
    8000142a:	fffff097          	auipc	ra,0xfffff
    8000142e:	136080e7          	jalr	310(ra) # 80000560 <panic>

0000000080001432 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001432:	1101                	add	sp,sp,-32
    80001434:	ec06                	sd	ra,24(sp)
    80001436:	e822                	sd	s0,16(sp)
    80001438:	e426                	sd	s1,8(sp)
    8000143a:	1000                	add	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000143c:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000143e:	00b67d63          	bgeu	a2,a1,80001458 <uvmdealloc+0x26>
    80001442:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001444:	6785                	lui	a5,0x1
    80001446:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001448:	00f60733          	add	a4,a2,a5
    8000144c:	76fd                	lui	a3,0xfffff
    8000144e:	8f75                	and	a4,a4,a3
    80001450:	97ae                	add	a5,a5,a1
    80001452:	8ff5                	and	a5,a5,a3
    80001454:	00f76863          	bltu	a4,a5,80001464 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001458:	8526                	mv	a0,s1
    8000145a:	60e2                	ld	ra,24(sp)
    8000145c:	6442                	ld	s0,16(sp)
    8000145e:	64a2                	ld	s1,8(sp)
    80001460:	6105                	add	sp,sp,32
    80001462:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001464:	8f99                	sub	a5,a5,a4
    80001466:	83b1                	srl	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001468:	4685                	li	a3,1
    8000146a:	0007861b          	sext.w	a2,a5
    8000146e:	85ba                	mv	a1,a4
    80001470:	00000097          	auipc	ra,0x0
    80001474:	e4e080e7          	jalr	-434(ra) # 800012be <uvmunmap>
    80001478:	b7c5                	j	80001458 <uvmdealloc+0x26>

000000008000147a <uvmalloc>:
  if(newsz < oldsz)
    8000147a:	0ab66b63          	bltu	a2,a1,80001530 <uvmalloc+0xb6>
{
    8000147e:	7139                	add	sp,sp,-64
    80001480:	fc06                	sd	ra,56(sp)
    80001482:	f822                	sd	s0,48(sp)
    80001484:	ec4e                	sd	s3,24(sp)
    80001486:	e852                	sd	s4,16(sp)
    80001488:	e456                	sd	s5,8(sp)
    8000148a:	0080                	add	s0,sp,64
    8000148c:	8aaa                	mv	s5,a0
    8000148e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001490:	6785                	lui	a5,0x1
    80001492:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001494:	95be                	add	a1,a1,a5
    80001496:	77fd                	lui	a5,0xfffff
    80001498:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000149c:	08c9fc63          	bgeu	s3,a2,80001534 <uvmalloc+0xba>
    800014a0:	f426                	sd	s1,40(sp)
    800014a2:	f04a                	sd	s2,32(sp)
    800014a4:	e05a                	sd	s6,0(sp)
    800014a6:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014a8:	0126eb13          	or	s6,a3,18
    mem = kalloc();
    800014ac:	fffff097          	auipc	ra,0xfffff
    800014b0:	69c080e7          	jalr	1692(ra) # 80000b48 <kalloc>
    800014b4:	84aa                	mv	s1,a0
    if(mem == 0){
    800014b6:	c915                	beqz	a0,800014ea <uvmalloc+0x70>
    memset(mem, 0, PGSIZE);
    800014b8:	6605                	lui	a2,0x1
    800014ba:	4581                	li	a1,0
    800014bc:	00000097          	auipc	ra,0x0
    800014c0:	878080e7          	jalr	-1928(ra) # 80000d34 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014c4:	875a                	mv	a4,s6
    800014c6:	86a6                	mv	a3,s1
    800014c8:	6605                	lui	a2,0x1
    800014ca:	85ca                	mv	a1,s2
    800014cc:	8556                	mv	a0,s5
    800014ce:	00000097          	auipc	ra,0x0
    800014d2:	c2a080e7          	jalr	-982(ra) # 800010f8 <mappages>
    800014d6:	ed05                	bnez	a0,8000150e <uvmalloc+0x94>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014d8:	6785                	lui	a5,0x1
    800014da:	993e                	add	s2,s2,a5
    800014dc:	fd4968e3          	bltu	s2,s4,800014ac <uvmalloc+0x32>
  return newsz;
    800014e0:	8552                	mv	a0,s4
    800014e2:	74a2                	ld	s1,40(sp)
    800014e4:	7902                	ld	s2,32(sp)
    800014e6:	6b02                	ld	s6,0(sp)
    800014e8:	a821                	j	80001500 <uvmalloc+0x86>
      uvmdealloc(pagetable, a, oldsz);
    800014ea:	864e                	mv	a2,s3
    800014ec:	85ca                	mv	a1,s2
    800014ee:	8556                	mv	a0,s5
    800014f0:	00000097          	auipc	ra,0x0
    800014f4:	f42080e7          	jalr	-190(ra) # 80001432 <uvmdealloc>
      return 0;
    800014f8:	4501                	li	a0,0
    800014fa:	74a2                	ld	s1,40(sp)
    800014fc:	7902                	ld	s2,32(sp)
    800014fe:	6b02                	ld	s6,0(sp)
}
    80001500:	70e2                	ld	ra,56(sp)
    80001502:	7442                	ld	s0,48(sp)
    80001504:	69e2                	ld	s3,24(sp)
    80001506:	6a42                	ld	s4,16(sp)
    80001508:	6aa2                	ld	s5,8(sp)
    8000150a:	6121                	add	sp,sp,64
    8000150c:	8082                	ret
      kfree(mem);
    8000150e:	8526                	mv	a0,s1
    80001510:	fffff097          	auipc	ra,0xfffff
    80001514:	53a080e7          	jalr	1338(ra) # 80000a4a <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001518:	864e                	mv	a2,s3
    8000151a:	85ca                	mv	a1,s2
    8000151c:	8556                	mv	a0,s5
    8000151e:	00000097          	auipc	ra,0x0
    80001522:	f14080e7          	jalr	-236(ra) # 80001432 <uvmdealloc>
      return 0;
    80001526:	4501                	li	a0,0
    80001528:	74a2                	ld	s1,40(sp)
    8000152a:	7902                	ld	s2,32(sp)
    8000152c:	6b02                	ld	s6,0(sp)
    8000152e:	bfc9                	j	80001500 <uvmalloc+0x86>
    return oldsz;
    80001530:	852e                	mv	a0,a1
}
    80001532:	8082                	ret
  return newsz;
    80001534:	8532                	mv	a0,a2
    80001536:	b7e9                	j	80001500 <uvmalloc+0x86>

0000000080001538 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001538:	7179                	add	sp,sp,-48
    8000153a:	f406                	sd	ra,40(sp)
    8000153c:	f022                	sd	s0,32(sp)
    8000153e:	ec26                	sd	s1,24(sp)
    80001540:	e84a                	sd	s2,16(sp)
    80001542:	e44e                	sd	s3,8(sp)
    80001544:	e052                	sd	s4,0(sp)
    80001546:	1800                	add	s0,sp,48
    80001548:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000154a:	84aa                	mv	s1,a0
    8000154c:	6905                	lui	s2,0x1
    8000154e:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001550:	4985                	li	s3,1
    80001552:	a829                	j	8000156c <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001554:	83a9                	srl	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001556:	00c79513          	sll	a0,a5,0xc
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	fde080e7          	jalr	-34(ra) # 80001538 <freewalk>
      pagetable[i] = 0;
    80001562:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001566:	04a1                	add	s1,s1,8
    80001568:	03248163          	beq	s1,s2,8000158a <freewalk+0x52>
    pte_t pte = pagetable[i];
    8000156c:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000156e:	00f7f713          	and	a4,a5,15
    80001572:	ff3701e3          	beq	a4,s3,80001554 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001576:	8b85                	and	a5,a5,1
    80001578:	d7fd                	beqz	a5,80001566 <freewalk+0x2e>
      panic("freewalk: leaf");
    8000157a:	00007517          	auipc	a0,0x7
    8000157e:	bee50513          	add	a0,a0,-1042 # 80008168 <digits+0x138>
    80001582:	fffff097          	auipc	ra,0xfffff
    80001586:	fde080e7          	jalr	-34(ra) # 80000560 <panic>
    }
  }
  kfree((void*)pagetable);
    8000158a:	8552                	mv	a0,s4
    8000158c:	fffff097          	auipc	ra,0xfffff
    80001590:	4be080e7          	jalr	1214(ra) # 80000a4a <kfree>
}
    80001594:	70a2                	ld	ra,40(sp)
    80001596:	7402                	ld	s0,32(sp)
    80001598:	64e2                	ld	s1,24(sp)
    8000159a:	6942                	ld	s2,16(sp)
    8000159c:	69a2                	ld	s3,8(sp)
    8000159e:	6a02                	ld	s4,0(sp)
    800015a0:	6145                	add	sp,sp,48
    800015a2:	8082                	ret

00000000800015a4 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015a4:	1101                	add	sp,sp,-32
    800015a6:	ec06                	sd	ra,24(sp)
    800015a8:	e822                	sd	s0,16(sp)
    800015aa:	e426                	sd	s1,8(sp)
    800015ac:	1000                	add	s0,sp,32
    800015ae:	84aa                	mv	s1,a0
  if(sz > 0)
    800015b0:	e999                	bnez	a1,800015c6 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015b2:	8526                	mv	a0,s1
    800015b4:	00000097          	auipc	ra,0x0
    800015b8:	f84080e7          	jalr	-124(ra) # 80001538 <freewalk>
}
    800015bc:	60e2                	ld	ra,24(sp)
    800015be:	6442                	ld	s0,16(sp)
    800015c0:	64a2                	ld	s1,8(sp)
    800015c2:	6105                	add	sp,sp,32
    800015c4:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015c6:	6785                	lui	a5,0x1
    800015c8:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015ca:	95be                	add	a1,a1,a5
    800015cc:	4685                	li	a3,1
    800015ce:	00c5d613          	srl	a2,a1,0xc
    800015d2:	4581                	li	a1,0
    800015d4:	00000097          	auipc	ra,0x0
    800015d8:	cea080e7          	jalr	-790(ra) # 800012be <uvmunmap>
    800015dc:	bfd9                	j	800015b2 <uvmfree+0xe>

00000000800015de <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015de:	c679                	beqz	a2,800016ac <uvmcopy+0xce>
{
    800015e0:	715d                	add	sp,sp,-80
    800015e2:	e486                	sd	ra,72(sp)
    800015e4:	e0a2                	sd	s0,64(sp)
    800015e6:	fc26                	sd	s1,56(sp)
    800015e8:	f84a                	sd	s2,48(sp)
    800015ea:	f44e                	sd	s3,40(sp)
    800015ec:	f052                	sd	s4,32(sp)
    800015ee:	ec56                	sd	s5,24(sp)
    800015f0:	e85a                	sd	s6,16(sp)
    800015f2:	e45e                	sd	s7,8(sp)
    800015f4:	0880                	add	s0,sp,80
    800015f6:	8b2a                	mv	s6,a0
    800015f8:	8aae                	mv	s5,a1
    800015fa:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015fc:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015fe:	4601                	li	a2,0
    80001600:	85ce                	mv	a1,s3
    80001602:	855a                	mv	a0,s6
    80001604:	00000097          	auipc	ra,0x0
    80001608:	a0c080e7          	jalr	-1524(ra) # 80001010 <walk>
    8000160c:	c531                	beqz	a0,80001658 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000160e:	6118                	ld	a4,0(a0)
    80001610:	00177793          	and	a5,a4,1
    80001614:	cbb1                	beqz	a5,80001668 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001616:	00a75593          	srl	a1,a4,0xa
    8000161a:	00c59b93          	sll	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000161e:	3ff77493          	and	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001622:	fffff097          	auipc	ra,0xfffff
    80001626:	526080e7          	jalr	1318(ra) # 80000b48 <kalloc>
    8000162a:	892a                	mv	s2,a0
    8000162c:	c939                	beqz	a0,80001682 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000162e:	6605                	lui	a2,0x1
    80001630:	85de                	mv	a1,s7
    80001632:	fffff097          	auipc	ra,0xfffff
    80001636:	75e080e7          	jalr	1886(ra) # 80000d90 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000163a:	8726                	mv	a4,s1
    8000163c:	86ca                	mv	a3,s2
    8000163e:	6605                	lui	a2,0x1
    80001640:	85ce                	mv	a1,s3
    80001642:	8556                	mv	a0,s5
    80001644:	00000097          	auipc	ra,0x0
    80001648:	ab4080e7          	jalr	-1356(ra) # 800010f8 <mappages>
    8000164c:	e515                	bnez	a0,80001678 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000164e:	6785                	lui	a5,0x1
    80001650:	99be                	add	s3,s3,a5
    80001652:	fb49e6e3          	bltu	s3,s4,800015fe <uvmcopy+0x20>
    80001656:	a081                	j	80001696 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001658:	00007517          	auipc	a0,0x7
    8000165c:	b2050513          	add	a0,a0,-1248 # 80008178 <digits+0x148>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	f00080e7          	jalr	-256(ra) # 80000560 <panic>
      panic("uvmcopy: page not present");
    80001668:	00007517          	auipc	a0,0x7
    8000166c:	b3050513          	add	a0,a0,-1232 # 80008198 <digits+0x168>
    80001670:	fffff097          	auipc	ra,0xfffff
    80001674:	ef0080e7          	jalr	-272(ra) # 80000560 <panic>
      kfree(mem);
    80001678:	854a                	mv	a0,s2
    8000167a:	fffff097          	auipc	ra,0xfffff
    8000167e:	3d0080e7          	jalr	976(ra) # 80000a4a <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001682:	4685                	li	a3,1
    80001684:	00c9d613          	srl	a2,s3,0xc
    80001688:	4581                	li	a1,0
    8000168a:	8556                	mv	a0,s5
    8000168c:	00000097          	auipc	ra,0x0
    80001690:	c32080e7          	jalr	-974(ra) # 800012be <uvmunmap>
  return -1;
    80001694:	557d                	li	a0,-1
}
    80001696:	60a6                	ld	ra,72(sp)
    80001698:	6406                	ld	s0,64(sp)
    8000169a:	74e2                	ld	s1,56(sp)
    8000169c:	7942                	ld	s2,48(sp)
    8000169e:	79a2                	ld	s3,40(sp)
    800016a0:	7a02                	ld	s4,32(sp)
    800016a2:	6ae2                	ld	s5,24(sp)
    800016a4:	6b42                	ld	s6,16(sp)
    800016a6:	6ba2                	ld	s7,8(sp)
    800016a8:	6161                	add	sp,sp,80
    800016aa:	8082                	ret
  return 0;
    800016ac:	4501                	li	a0,0
}
    800016ae:	8082                	ret

00000000800016b0 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016b0:	1141                	add	sp,sp,-16
    800016b2:	e406                	sd	ra,8(sp)
    800016b4:	e022                	sd	s0,0(sp)
    800016b6:	0800                	add	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016b8:	4601                	li	a2,0
    800016ba:	00000097          	auipc	ra,0x0
    800016be:	956080e7          	jalr	-1706(ra) # 80001010 <walk>
  if(pte == 0)
    800016c2:	c901                	beqz	a0,800016d2 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016c4:	611c                	ld	a5,0(a0)
    800016c6:	9bbd                	and	a5,a5,-17
    800016c8:	e11c                	sd	a5,0(a0)
}
    800016ca:	60a2                	ld	ra,8(sp)
    800016cc:	6402                	ld	s0,0(sp)
    800016ce:	0141                	add	sp,sp,16
    800016d0:	8082                	ret
    panic("uvmclear");
    800016d2:	00007517          	auipc	a0,0x7
    800016d6:	ae650513          	add	a0,a0,-1306 # 800081b8 <digits+0x188>
    800016da:	fffff097          	auipc	ra,0xfffff
    800016de:	e86080e7          	jalr	-378(ra) # 80000560 <panic>

00000000800016e2 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016e2:	c6bd                	beqz	a3,80001750 <copyout+0x6e>
{
    800016e4:	715d                	add	sp,sp,-80
    800016e6:	e486                	sd	ra,72(sp)
    800016e8:	e0a2                	sd	s0,64(sp)
    800016ea:	fc26                	sd	s1,56(sp)
    800016ec:	f84a                	sd	s2,48(sp)
    800016ee:	f44e                	sd	s3,40(sp)
    800016f0:	f052                	sd	s4,32(sp)
    800016f2:	ec56                	sd	s5,24(sp)
    800016f4:	e85a                	sd	s6,16(sp)
    800016f6:	e45e                	sd	s7,8(sp)
    800016f8:	e062                	sd	s8,0(sp)
    800016fa:	0880                	add	s0,sp,80
    800016fc:	8b2a                	mv	s6,a0
    800016fe:	8c2e                	mv	s8,a1
    80001700:	8a32                	mv	s4,a2
    80001702:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001704:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001706:	6a85                	lui	s5,0x1
    80001708:	a015                	j	8000172c <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000170a:	9562                	add	a0,a0,s8
    8000170c:	0004861b          	sext.w	a2,s1
    80001710:	85d2                	mv	a1,s4
    80001712:	41250533          	sub	a0,a0,s2
    80001716:	fffff097          	auipc	ra,0xfffff
    8000171a:	67a080e7          	jalr	1658(ra) # 80000d90 <memmove>

    len -= n;
    8000171e:	409989b3          	sub	s3,s3,s1
    src += n;
    80001722:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001724:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001728:	02098263          	beqz	s3,8000174c <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000172c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001730:	85ca                	mv	a1,s2
    80001732:	855a                	mv	a0,s6
    80001734:	00000097          	auipc	ra,0x0
    80001738:	982080e7          	jalr	-1662(ra) # 800010b6 <walkaddr>
    if(pa0 == 0)
    8000173c:	cd01                	beqz	a0,80001754 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000173e:	418904b3          	sub	s1,s2,s8
    80001742:	94d6                	add	s1,s1,s5
    if(n > len)
    80001744:	fc99f3e3          	bgeu	s3,s1,8000170a <copyout+0x28>
    80001748:	84ce                	mv	s1,s3
    8000174a:	b7c1                	j	8000170a <copyout+0x28>
  }
  return 0;
    8000174c:	4501                	li	a0,0
    8000174e:	a021                	j	80001756 <copyout+0x74>
    80001750:	4501                	li	a0,0
}
    80001752:	8082                	ret
      return -1;
    80001754:	557d                	li	a0,-1
}
    80001756:	60a6                	ld	ra,72(sp)
    80001758:	6406                	ld	s0,64(sp)
    8000175a:	74e2                	ld	s1,56(sp)
    8000175c:	7942                	ld	s2,48(sp)
    8000175e:	79a2                	ld	s3,40(sp)
    80001760:	7a02                	ld	s4,32(sp)
    80001762:	6ae2                	ld	s5,24(sp)
    80001764:	6b42                	ld	s6,16(sp)
    80001766:	6ba2                	ld	s7,8(sp)
    80001768:	6c02                	ld	s8,0(sp)
    8000176a:	6161                	add	sp,sp,80
    8000176c:	8082                	ret

000000008000176e <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000176e:	caa5                	beqz	a3,800017de <copyin+0x70>
{
    80001770:	715d                	add	sp,sp,-80
    80001772:	e486                	sd	ra,72(sp)
    80001774:	e0a2                	sd	s0,64(sp)
    80001776:	fc26                	sd	s1,56(sp)
    80001778:	f84a                	sd	s2,48(sp)
    8000177a:	f44e                	sd	s3,40(sp)
    8000177c:	f052                	sd	s4,32(sp)
    8000177e:	ec56                	sd	s5,24(sp)
    80001780:	e85a                	sd	s6,16(sp)
    80001782:	e45e                	sd	s7,8(sp)
    80001784:	e062                	sd	s8,0(sp)
    80001786:	0880                	add	s0,sp,80
    80001788:	8b2a                	mv	s6,a0
    8000178a:	8a2e                	mv	s4,a1
    8000178c:	8c32                	mv	s8,a2
    8000178e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001790:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001792:	6a85                	lui	s5,0x1
    80001794:	a01d                	j	800017ba <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001796:	018505b3          	add	a1,a0,s8
    8000179a:	0004861b          	sext.w	a2,s1
    8000179e:	412585b3          	sub	a1,a1,s2
    800017a2:	8552                	mv	a0,s4
    800017a4:	fffff097          	auipc	ra,0xfffff
    800017a8:	5ec080e7          	jalr	1516(ra) # 80000d90 <memmove>

    len -= n;
    800017ac:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017b0:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017b2:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017b6:	02098263          	beqz	s3,800017da <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017ba:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017be:	85ca                	mv	a1,s2
    800017c0:	855a                	mv	a0,s6
    800017c2:	00000097          	auipc	ra,0x0
    800017c6:	8f4080e7          	jalr	-1804(ra) # 800010b6 <walkaddr>
    if(pa0 == 0)
    800017ca:	cd01                	beqz	a0,800017e2 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017cc:	418904b3          	sub	s1,s2,s8
    800017d0:	94d6                	add	s1,s1,s5
    if(n > len)
    800017d2:	fc99f2e3          	bgeu	s3,s1,80001796 <copyin+0x28>
    800017d6:	84ce                	mv	s1,s3
    800017d8:	bf7d                	j	80001796 <copyin+0x28>
  }
  return 0;
    800017da:	4501                	li	a0,0
    800017dc:	a021                	j	800017e4 <copyin+0x76>
    800017de:	4501                	li	a0,0
}
    800017e0:	8082                	ret
      return -1;
    800017e2:	557d                	li	a0,-1
}
    800017e4:	60a6                	ld	ra,72(sp)
    800017e6:	6406                	ld	s0,64(sp)
    800017e8:	74e2                	ld	s1,56(sp)
    800017ea:	7942                	ld	s2,48(sp)
    800017ec:	79a2                	ld	s3,40(sp)
    800017ee:	7a02                	ld	s4,32(sp)
    800017f0:	6ae2                	ld	s5,24(sp)
    800017f2:	6b42                	ld	s6,16(sp)
    800017f4:	6ba2                	ld	s7,8(sp)
    800017f6:	6c02                	ld	s8,0(sp)
    800017f8:	6161                	add	sp,sp,80
    800017fa:	8082                	ret

00000000800017fc <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017fc:	cacd                	beqz	a3,800018ae <copyinstr+0xb2>
{
    800017fe:	715d                	add	sp,sp,-80
    80001800:	e486                	sd	ra,72(sp)
    80001802:	e0a2                	sd	s0,64(sp)
    80001804:	fc26                	sd	s1,56(sp)
    80001806:	f84a                	sd	s2,48(sp)
    80001808:	f44e                	sd	s3,40(sp)
    8000180a:	f052                	sd	s4,32(sp)
    8000180c:	ec56                	sd	s5,24(sp)
    8000180e:	e85a                	sd	s6,16(sp)
    80001810:	e45e                	sd	s7,8(sp)
    80001812:	0880                	add	s0,sp,80
    80001814:	8a2a                	mv	s4,a0
    80001816:	8b2e                	mv	s6,a1
    80001818:	8bb2                	mv	s7,a2
    8000181a:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    8000181c:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000181e:	6985                	lui	s3,0x1
    80001820:	a825                	j	80001858 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001822:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001826:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001828:	37fd                	addw	a5,a5,-1
    8000182a:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000182e:	60a6                	ld	ra,72(sp)
    80001830:	6406                	ld	s0,64(sp)
    80001832:	74e2                	ld	s1,56(sp)
    80001834:	7942                	ld	s2,48(sp)
    80001836:	79a2                	ld	s3,40(sp)
    80001838:	7a02                	ld	s4,32(sp)
    8000183a:	6ae2                	ld	s5,24(sp)
    8000183c:	6b42                	ld	s6,16(sp)
    8000183e:	6ba2                	ld	s7,8(sp)
    80001840:	6161                	add	sp,sp,80
    80001842:	8082                	ret
    80001844:	fff90713          	add	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001848:	9742                	add	a4,a4,a6
      --max;
    8000184a:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    8000184e:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001852:	04e58663          	beq	a1,a4,8000189e <copyinstr+0xa2>
{
    80001856:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80001858:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000185c:	85a6                	mv	a1,s1
    8000185e:	8552                	mv	a0,s4
    80001860:	00000097          	auipc	ra,0x0
    80001864:	856080e7          	jalr	-1962(ra) # 800010b6 <walkaddr>
    if(pa0 == 0)
    80001868:	cd0d                	beqz	a0,800018a2 <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    8000186a:	417486b3          	sub	a3,s1,s7
    8000186e:	96ce                	add	a3,a3,s3
    if(n > max)
    80001870:	00d97363          	bgeu	s2,a3,80001876 <copyinstr+0x7a>
    80001874:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001876:	955e                	add	a0,a0,s7
    80001878:	8d05                	sub	a0,a0,s1
    while(n > 0){
    8000187a:	c695                	beqz	a3,800018a6 <copyinstr+0xaa>
    8000187c:	87da                	mv	a5,s6
    8000187e:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001880:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001884:	96da                	add	a3,a3,s6
    80001886:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001888:	00f60733          	add	a4,a2,a5
    8000188c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffda310>
    80001890:	db49                	beqz	a4,80001822 <copyinstr+0x26>
        *dst = *p;
    80001892:	00e78023          	sb	a4,0(a5)
      dst++;
    80001896:	0785                	add	a5,a5,1
    while(n > 0){
    80001898:	fed797e3          	bne	a5,a3,80001886 <copyinstr+0x8a>
    8000189c:	b765                	j	80001844 <copyinstr+0x48>
    8000189e:	4781                	li	a5,0
    800018a0:	b761                	j	80001828 <copyinstr+0x2c>
      return -1;
    800018a2:	557d                	li	a0,-1
    800018a4:	b769                	j	8000182e <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    800018a6:	6b85                	lui	s7,0x1
    800018a8:	9ba6                	add	s7,s7,s1
    800018aa:	87da                	mv	a5,s6
    800018ac:	b76d                	j	80001856 <copyinstr+0x5a>
  int got_null = 0;
    800018ae:	4781                	li	a5,0
  if(got_null){
    800018b0:	37fd                	addw	a5,a5,-1
    800018b2:	0007851b          	sext.w	a0,a5
}
    800018b6:	8082                	ret

00000000800018b8 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800018b8:	7139                	add	sp,sp,-64
    800018ba:	fc06                	sd	ra,56(sp)
    800018bc:	f822                	sd	s0,48(sp)
    800018be:	f426                	sd	s1,40(sp)
    800018c0:	f04a                	sd	s2,32(sp)
    800018c2:	ec4e                	sd	s3,24(sp)
    800018c4:	e852                	sd	s4,16(sp)
    800018c6:	e456                	sd	s5,8(sp)
    800018c8:	e05a                	sd	s6,0(sp)
    800018ca:	0080                	add	s0,sp,64
    800018cc:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ce:	00012497          	auipc	s1,0x12
    800018d2:	04248493          	add	s1,s1,66 # 80013910 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800018d6:	8b26                	mv	s6,s1
    800018d8:	faaab937          	lui	s2,0xfaaab
    800018dc:	aab90913          	add	s2,s2,-1365 # fffffffffaaaaaab <end+0xffffffff7aa85dbb>
    800018e0:	0932                	sll	s2,s2,0xc
    800018e2:	aab90913          	add	s2,s2,-1365
    800018e6:	0932                	sll	s2,s2,0xc
    800018e8:	aab90913          	add	s2,s2,-1365
    800018ec:	0932                	sll	s2,s2,0xc
    800018ee:	aab90913          	add	s2,s2,-1365
    800018f2:	040009b7          	lui	s3,0x4000
    800018f6:	19fd                	add	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018f8:	09b2                	sll	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018fa:	00018a97          	auipc	s5,0x18
    800018fe:	016a8a93          	add	s5,s5,22 # 80019910 <tickslock>
    char *pa = kalloc();
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	246080e7          	jalr	582(ra) # 80000b48 <kalloc>
    8000190a:	862a                	mv	a2,a0
    if(pa == 0)
    8000190c:	c121                	beqz	a0,8000194c <proc_mapstacks+0x94>
    uint64 va = KSTACK((int) (p - proc));
    8000190e:	416485b3          	sub	a1,s1,s6
    80001912:	859d                	sra	a1,a1,0x7
    80001914:	032585b3          	mul	a1,a1,s2
    80001918:	2585                	addw	a1,a1,1
    8000191a:	00d5959b          	sllw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000191e:	4719                	li	a4,6
    80001920:	6685                	lui	a3,0x1
    80001922:	40b985b3          	sub	a1,s3,a1
    80001926:	8552                	mv	a0,s4
    80001928:	00000097          	auipc	ra,0x0
    8000192c:	870080e7          	jalr	-1936(ra) # 80001198 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001930:	18048493          	add	s1,s1,384
    80001934:	fd5497e3          	bne	s1,s5,80001902 <proc_mapstacks+0x4a>
  }
}
    80001938:	70e2                	ld	ra,56(sp)
    8000193a:	7442                	ld	s0,48(sp)
    8000193c:	74a2                	ld	s1,40(sp)
    8000193e:	7902                	ld	s2,32(sp)
    80001940:	69e2                	ld	s3,24(sp)
    80001942:	6a42                	ld	s4,16(sp)
    80001944:	6aa2                	ld	s5,8(sp)
    80001946:	6b02                	ld	s6,0(sp)
    80001948:	6121                	add	sp,sp,64
    8000194a:	8082                	ret
      panic("kalloc");
    8000194c:	00007517          	auipc	a0,0x7
    80001950:	87c50513          	add	a0,a0,-1924 # 800081c8 <digits+0x198>
    80001954:	fffff097          	auipc	ra,0xfffff
    80001958:	c0c080e7          	jalr	-1012(ra) # 80000560 <panic>

000000008000195c <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000195c:	7139                	add	sp,sp,-64
    8000195e:	fc06                	sd	ra,56(sp)
    80001960:	f822                	sd	s0,48(sp)
    80001962:	f426                	sd	s1,40(sp)
    80001964:	f04a                	sd	s2,32(sp)
    80001966:	ec4e                	sd	s3,24(sp)
    80001968:	e852                	sd	s4,16(sp)
    8000196a:	e456                	sd	s5,8(sp)
    8000196c:	e05a                	sd	s6,0(sp)
    8000196e:	0080                	add	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001970:	00007597          	auipc	a1,0x7
    80001974:	86058593          	add	a1,a1,-1952 # 800081d0 <digits+0x1a0>
    80001978:	00012517          	auipc	a0,0x12
    8000197c:	b6850513          	add	a0,a0,-1176 # 800134e0 <pid_lock>
    80001980:	fffff097          	auipc	ra,0xfffff
    80001984:	228080e7          	jalr	552(ra) # 80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001988:	00007597          	auipc	a1,0x7
    8000198c:	85058593          	add	a1,a1,-1968 # 800081d8 <digits+0x1a8>
    80001990:	00012517          	auipc	a0,0x12
    80001994:	b6850513          	add	a0,a0,-1176 # 800134f8 <wait_lock>
    80001998:	fffff097          	auipc	ra,0xfffff
    8000199c:	210080e7          	jalr	528(ra) # 80000ba8 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019a0:	00012497          	auipc	s1,0x12
    800019a4:	f7048493          	add	s1,s1,-144 # 80013910 <proc>
      initlock(&p->lock, "proc");
    800019a8:	00007b17          	auipc	s6,0x7
    800019ac:	840b0b13          	add	s6,s6,-1984 # 800081e8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    800019b0:	8aa6                	mv	s5,s1
    800019b2:	faaab937          	lui	s2,0xfaaab
    800019b6:	aab90913          	add	s2,s2,-1365 # fffffffffaaaaaab <end+0xffffffff7aa85dbb>
    800019ba:	0932                	sll	s2,s2,0xc
    800019bc:	aab90913          	add	s2,s2,-1365
    800019c0:	0932                	sll	s2,s2,0xc
    800019c2:	aab90913          	add	s2,s2,-1365
    800019c6:	0932                	sll	s2,s2,0xc
    800019c8:	aab90913          	add	s2,s2,-1365
    800019cc:	040009b7          	lui	s3,0x4000
    800019d0:	19fd                	add	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019d2:	09b2                	sll	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019d4:	00018a17          	auipc	s4,0x18
    800019d8:	f3ca0a13          	add	s4,s4,-196 # 80019910 <tickslock>
      initlock(&p->lock, "proc");
    800019dc:	85da                	mv	a1,s6
    800019de:	8526                	mv	a0,s1
    800019e0:	fffff097          	auipc	ra,0xfffff
    800019e4:	1c8080e7          	jalr	456(ra) # 80000ba8 <initlock>
      p->state = UNUSED;
    800019e8:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800019ec:	415487b3          	sub	a5,s1,s5
    800019f0:	879d                	sra	a5,a5,0x7
    800019f2:	032787b3          	mul	a5,a5,s2
    800019f6:	2785                	addw	a5,a5,1
    800019f8:	00d7979b          	sllw	a5,a5,0xd
    800019fc:	40f987b3          	sub	a5,s3,a5
    80001a00:	ecbc                	sd	a5,88(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a02:	18048493          	add	s1,s1,384
    80001a06:	fd449be3          	bne	s1,s4,800019dc <procinit+0x80>
  }
}
    80001a0a:	70e2                	ld	ra,56(sp)
    80001a0c:	7442                	ld	s0,48(sp)
    80001a0e:	74a2                	ld	s1,40(sp)
    80001a10:	7902                	ld	s2,32(sp)
    80001a12:	69e2                	ld	s3,24(sp)
    80001a14:	6a42                	ld	s4,16(sp)
    80001a16:	6aa2                	ld	s5,8(sp)
    80001a18:	6b02                	ld	s6,0(sp)
    80001a1a:	6121                	add	sp,sp,64
    80001a1c:	8082                	ret

0000000080001a1e <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a1e:	1141                	add	sp,sp,-16
    80001a20:	e422                	sd	s0,8(sp)
    80001a22:	0800                	add	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a24:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a26:	2501                	sext.w	a0,a0
    80001a28:	6422                	ld	s0,8(sp)
    80001a2a:	0141                	add	sp,sp,16
    80001a2c:	8082                	ret

0000000080001a2e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001a2e:	1141                	add	sp,sp,-16
    80001a30:	e422                	sd	s0,8(sp)
    80001a32:	0800                	add	s0,sp,16
    80001a34:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a36:	2781                	sext.w	a5,a5
    80001a38:	079e                	sll	a5,a5,0x7
  return c;
}
    80001a3a:	00012517          	auipc	a0,0x12
    80001a3e:	ad650513          	add	a0,a0,-1322 # 80013510 <cpus>
    80001a42:	953e                	add	a0,a0,a5
    80001a44:	6422                	ld	s0,8(sp)
    80001a46:	0141                	add	sp,sp,16
    80001a48:	8082                	ret

0000000080001a4a <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001a4a:	1101                	add	sp,sp,-32
    80001a4c:	ec06                	sd	ra,24(sp)
    80001a4e:	e822                	sd	s0,16(sp)
    80001a50:	e426                	sd	s1,8(sp)
    80001a52:	1000                	add	s0,sp,32
  push_off();
    80001a54:	fffff097          	auipc	ra,0xfffff
    80001a58:	198080e7          	jalr	408(ra) # 80000bec <push_off>
    80001a5c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a5e:	2781                	sext.w	a5,a5
    80001a60:	079e                	sll	a5,a5,0x7
    80001a62:	00012717          	auipc	a4,0x12
    80001a66:	a7e70713          	add	a4,a4,-1410 # 800134e0 <pid_lock>
    80001a6a:	97ba                	add	a5,a5,a4
    80001a6c:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a6e:	fffff097          	auipc	ra,0xfffff
    80001a72:	21e080e7          	jalr	542(ra) # 80000c8c <pop_off>
  return p;
}
    80001a76:	8526                	mv	a0,s1
    80001a78:	60e2                	ld	ra,24(sp)
    80001a7a:	6442                	ld	s0,16(sp)
    80001a7c:	64a2                	ld	s1,8(sp)
    80001a7e:	6105                	add	sp,sp,32
    80001a80:	8082                	ret

0000000080001a82 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a82:	1141                	add	sp,sp,-16
    80001a84:	e406                	sd	ra,8(sp)
    80001a86:	e022                	sd	s0,0(sp)
    80001a88:	0800                	add	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a8a:	00000097          	auipc	ra,0x0
    80001a8e:	fc0080e7          	jalr	-64(ra) # 80001a4a <myproc>
    80001a92:	fffff097          	auipc	ra,0xfffff
    80001a96:	25a080e7          	jalr	602(ra) # 80000cec <release>

  if (first) {
    80001a9a:	00009797          	auipc	a5,0x9
    80001a9e:	7567a783          	lw	a5,1878(a5) # 8000b1f0 <first.1>
    80001aa2:	eb89                	bnez	a5,80001ab4 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001aa4:	00001097          	auipc	ra,0x1
    80001aa8:	c70080e7          	jalr	-912(ra) # 80002714 <usertrapret>
}
    80001aac:	60a2                	ld	ra,8(sp)
    80001aae:	6402                	ld	s0,0(sp)
    80001ab0:	0141                	add	sp,sp,16
    80001ab2:	8082                	ret
    first = 0;
    80001ab4:	00009797          	auipc	a5,0x9
    80001ab8:	7207ae23          	sw	zero,1852(a5) # 8000b1f0 <first.1>
    fsinit(ROOTDEV);
    80001abc:	4505                	li	a0,1
    80001abe:	00002097          	auipc	ra,0x2
    80001ac2:	bec080e7          	jalr	-1044(ra) # 800036aa <fsinit>
    80001ac6:	bff9                	j	80001aa4 <forkret+0x22>

0000000080001ac8 <allocpid>:
{
    80001ac8:	1101                	add	sp,sp,-32
    80001aca:	ec06                	sd	ra,24(sp)
    80001acc:	e822                	sd	s0,16(sp)
    80001ace:	e426                	sd	s1,8(sp)
    80001ad0:	e04a                	sd	s2,0(sp)
    80001ad2:	1000                	add	s0,sp,32
  acquire(&pid_lock);
    80001ad4:	00012917          	auipc	s2,0x12
    80001ad8:	a0c90913          	add	s2,s2,-1524 # 800134e0 <pid_lock>
    80001adc:	854a                	mv	a0,s2
    80001ade:	fffff097          	auipc	ra,0xfffff
    80001ae2:	15a080e7          	jalr	346(ra) # 80000c38 <acquire>
  pid = nextpid;
    80001ae6:	00009797          	auipc	a5,0x9
    80001aea:	70e78793          	add	a5,a5,1806 # 8000b1f4 <nextpid>
    80001aee:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001af0:	0014871b          	addw	a4,s1,1
    80001af4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001af6:	854a                	mv	a0,s2
    80001af8:	fffff097          	auipc	ra,0xfffff
    80001afc:	1f4080e7          	jalr	500(ra) # 80000cec <release>
}
    80001b00:	8526                	mv	a0,s1
    80001b02:	60e2                	ld	ra,24(sp)
    80001b04:	6442                	ld	s0,16(sp)
    80001b06:	64a2                	ld	s1,8(sp)
    80001b08:	6902                	ld	s2,0(sp)
    80001b0a:	6105                	add	sp,sp,32
    80001b0c:	8082                	ret

0000000080001b0e <proc_pagetable>:
{
    80001b0e:	1101                	add	sp,sp,-32
    80001b10:	ec06                	sd	ra,24(sp)
    80001b12:	e822                	sd	s0,16(sp)
    80001b14:	e426                	sd	s1,8(sp)
    80001b16:	e04a                	sd	s2,0(sp)
    80001b18:	1000                	add	s0,sp,32
    80001b1a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b1c:	00000097          	auipc	ra,0x0
    80001b20:	876080e7          	jalr	-1930(ra) # 80001392 <uvmcreate>
    80001b24:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b26:	c121                	beqz	a0,80001b66 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b28:	4729                	li	a4,10
    80001b2a:	00005697          	auipc	a3,0x5
    80001b2e:	4d668693          	add	a3,a3,1238 # 80007000 <_trampoline>
    80001b32:	6605                	lui	a2,0x1
    80001b34:	040005b7          	lui	a1,0x4000
    80001b38:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b3a:	05b2                	sll	a1,a1,0xc
    80001b3c:	fffff097          	auipc	ra,0xfffff
    80001b40:	5bc080e7          	jalr	1468(ra) # 800010f8 <mappages>
    80001b44:	02054863          	bltz	a0,80001b74 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b48:	4719                	li	a4,6
    80001b4a:	07093683          	ld	a3,112(s2)
    80001b4e:	6605                	lui	a2,0x1
    80001b50:	020005b7          	lui	a1,0x2000
    80001b54:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b56:	05b6                	sll	a1,a1,0xd
    80001b58:	8526                	mv	a0,s1
    80001b5a:	fffff097          	auipc	ra,0xfffff
    80001b5e:	59e080e7          	jalr	1438(ra) # 800010f8 <mappages>
    80001b62:	02054163          	bltz	a0,80001b84 <proc_pagetable+0x76>
}
    80001b66:	8526                	mv	a0,s1
    80001b68:	60e2                	ld	ra,24(sp)
    80001b6a:	6442                	ld	s0,16(sp)
    80001b6c:	64a2                	ld	s1,8(sp)
    80001b6e:	6902                	ld	s2,0(sp)
    80001b70:	6105                	add	sp,sp,32
    80001b72:	8082                	ret
    uvmfree(pagetable, 0);
    80001b74:	4581                	li	a1,0
    80001b76:	8526                	mv	a0,s1
    80001b78:	00000097          	auipc	ra,0x0
    80001b7c:	a2c080e7          	jalr	-1492(ra) # 800015a4 <uvmfree>
    return 0;
    80001b80:	4481                	li	s1,0
    80001b82:	b7d5                	j	80001b66 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b84:	4681                	li	a3,0
    80001b86:	4605                	li	a2,1
    80001b88:	040005b7          	lui	a1,0x4000
    80001b8c:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b8e:	05b2                	sll	a1,a1,0xc
    80001b90:	8526                	mv	a0,s1
    80001b92:	fffff097          	auipc	ra,0xfffff
    80001b96:	72c080e7          	jalr	1836(ra) # 800012be <uvmunmap>
    uvmfree(pagetable, 0);
    80001b9a:	4581                	li	a1,0
    80001b9c:	8526                	mv	a0,s1
    80001b9e:	00000097          	auipc	ra,0x0
    80001ba2:	a06080e7          	jalr	-1530(ra) # 800015a4 <uvmfree>
    return 0;
    80001ba6:	4481                	li	s1,0
    80001ba8:	bf7d                	j	80001b66 <proc_pagetable+0x58>

0000000080001baa <proc_freepagetable>:
{
    80001baa:	1101                	add	sp,sp,-32
    80001bac:	ec06                	sd	ra,24(sp)
    80001bae:	e822                	sd	s0,16(sp)
    80001bb0:	e426                	sd	s1,8(sp)
    80001bb2:	e04a                	sd	s2,0(sp)
    80001bb4:	1000                	add	s0,sp,32
    80001bb6:	84aa                	mv	s1,a0
    80001bb8:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bba:	4681                	li	a3,0
    80001bbc:	4605                	li	a2,1
    80001bbe:	040005b7          	lui	a1,0x4000
    80001bc2:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bc4:	05b2                	sll	a1,a1,0xc
    80001bc6:	fffff097          	auipc	ra,0xfffff
    80001bca:	6f8080e7          	jalr	1784(ra) # 800012be <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bce:	4681                	li	a3,0
    80001bd0:	4605                	li	a2,1
    80001bd2:	020005b7          	lui	a1,0x2000
    80001bd6:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bd8:	05b6                	sll	a1,a1,0xd
    80001bda:	8526                	mv	a0,s1
    80001bdc:	fffff097          	auipc	ra,0xfffff
    80001be0:	6e2080e7          	jalr	1762(ra) # 800012be <uvmunmap>
  uvmfree(pagetable, sz);
    80001be4:	85ca                	mv	a1,s2
    80001be6:	8526                	mv	a0,s1
    80001be8:	00000097          	auipc	ra,0x0
    80001bec:	9bc080e7          	jalr	-1604(ra) # 800015a4 <uvmfree>
}
    80001bf0:	60e2                	ld	ra,24(sp)
    80001bf2:	6442                	ld	s0,16(sp)
    80001bf4:	64a2                	ld	s1,8(sp)
    80001bf6:	6902                	ld	s2,0(sp)
    80001bf8:	6105                	add	sp,sp,32
    80001bfa:	8082                	ret

0000000080001bfc <freeproc>:
{
    80001bfc:	1101                	add	sp,sp,-32
    80001bfe:	ec06                	sd	ra,24(sp)
    80001c00:	e822                	sd	s0,16(sp)
    80001c02:	e426                	sd	s1,8(sp)
    80001c04:	1000                	add	s0,sp,32
    80001c06:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c08:	7928                	ld	a0,112(a0)
    80001c0a:	c509                	beqz	a0,80001c14 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c0c:	fffff097          	auipc	ra,0xfffff
    80001c10:	e3e080e7          	jalr	-450(ra) # 80000a4a <kfree>
  p->trapframe = 0;
    80001c14:	0604b823          	sd	zero,112(s1)
  if(p->pagetable)
    80001c18:	74a8                	ld	a0,104(s1)
    80001c1a:	c511                	beqz	a0,80001c26 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c1c:	70ac                	ld	a1,96(s1)
    80001c1e:	00000097          	auipc	ra,0x0
    80001c22:	f8c080e7          	jalr	-116(ra) # 80001baa <proc_freepagetable>
  p->pagetable = 0;
    80001c26:	0604b423          	sd	zero,104(s1)
  p->sz = 0;
    80001c2a:	0604b023          	sd	zero,96(s1)
  p->pid = 0;
    80001c2e:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c32:	0404b823          	sd	zero,80(s1)
  p->name[0] = 0;
    80001c36:	16048823          	sb	zero,368(s1)
  p->chan = 0;
    80001c3a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c3e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c42:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c46:	0004ac23          	sw	zero,24(s1)
}
    80001c4a:	60e2                	ld	ra,24(sp)
    80001c4c:	6442                	ld	s0,16(sp)
    80001c4e:	64a2                	ld	s1,8(sp)
    80001c50:	6105                	add	sp,sp,32
    80001c52:	8082                	ret

0000000080001c54 <allocproc>:
{
    80001c54:	1101                	add	sp,sp,-32
    80001c56:	ec06                	sd	ra,24(sp)
    80001c58:	e822                	sd	s0,16(sp)
    80001c5a:	e426                	sd	s1,8(sp)
    80001c5c:	e04a                	sd	s2,0(sp)
    80001c5e:	1000                	add	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c60:	00012497          	auipc	s1,0x12
    80001c64:	cb048493          	add	s1,s1,-848 # 80013910 <proc>
    80001c68:	00018917          	auipc	s2,0x18
    80001c6c:	ca890913          	add	s2,s2,-856 # 80019910 <tickslock>
    acquire(&p->lock);
    80001c70:	8526                	mv	a0,s1
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	fc6080e7          	jalr	-58(ra) # 80000c38 <acquire>
    if(p->state == UNUSED) {
    80001c7a:	4c9c                	lw	a5,24(s1)
    80001c7c:	cf81                	beqz	a5,80001c94 <allocproc+0x40>
      release(&p->lock);
    80001c7e:	8526                	mv	a0,s1
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	06c080e7          	jalr	108(ra) # 80000cec <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c88:	18048493          	add	s1,s1,384
    80001c8c:	ff2492e3          	bne	s1,s2,80001c70 <allocproc+0x1c>
  return 0;
    80001c90:	4481                	li	s1,0
    80001c92:	a889                	j	80001ce4 <allocproc+0x90>
  p->pid = allocpid();
    80001c94:	00000097          	auipc	ra,0x0
    80001c98:	e34080e7          	jalr	-460(ra) # 80001ac8 <allocpid>
    80001c9c:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c9e:	4785                	li	a5,1
    80001ca0:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ca2:	fffff097          	auipc	ra,0xfffff
    80001ca6:	ea6080e7          	jalr	-346(ra) # 80000b48 <kalloc>
    80001caa:	892a                	mv	s2,a0
    80001cac:	f8a8                	sd	a0,112(s1)
    80001cae:	c131                	beqz	a0,80001cf2 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001cb0:	8526                	mv	a0,s1
    80001cb2:	00000097          	auipc	ra,0x0
    80001cb6:	e5c080e7          	jalr	-420(ra) # 80001b0e <proc_pagetable>
    80001cba:	892a                	mv	s2,a0
    80001cbc:	f4a8                	sd	a0,104(s1)
  if(p->pagetable == 0){
    80001cbe:	c531                	beqz	a0,80001d0a <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001cc0:	07000613          	li	a2,112
    80001cc4:	4581                	li	a1,0
    80001cc6:	07848513          	add	a0,s1,120
    80001cca:	fffff097          	auipc	ra,0xfffff
    80001cce:	06a080e7          	jalr	106(ra) # 80000d34 <memset>
  p->context.ra = (uint64)forkret;
    80001cd2:	00000797          	auipc	a5,0x0
    80001cd6:	db078793          	add	a5,a5,-592 # 80001a82 <forkret>
    80001cda:	fcbc                	sd	a5,120(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cdc:	6cbc                	ld	a5,88(s1)
    80001cde:	6705                	lui	a4,0x1
    80001ce0:	97ba                	add	a5,a5,a4
    80001ce2:	e0dc                	sd	a5,128(s1)
}
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	60e2                	ld	ra,24(sp)
    80001ce8:	6442                	ld	s0,16(sp)
    80001cea:	64a2                	ld	s1,8(sp)
    80001cec:	6902                	ld	s2,0(sp)
    80001cee:	6105                	add	sp,sp,32
    80001cf0:	8082                	ret
    freeproc(p);
    80001cf2:	8526                	mv	a0,s1
    80001cf4:	00000097          	auipc	ra,0x0
    80001cf8:	f08080e7          	jalr	-248(ra) # 80001bfc <freeproc>
    release(&p->lock);
    80001cfc:	8526                	mv	a0,s1
    80001cfe:	fffff097          	auipc	ra,0xfffff
    80001d02:	fee080e7          	jalr	-18(ra) # 80000cec <release>
    return 0;
    80001d06:	84ca                	mv	s1,s2
    80001d08:	bff1                	j	80001ce4 <allocproc+0x90>
    freeproc(p);
    80001d0a:	8526                	mv	a0,s1
    80001d0c:	00000097          	auipc	ra,0x0
    80001d10:	ef0080e7          	jalr	-272(ra) # 80001bfc <freeproc>
    release(&p->lock);
    80001d14:	8526                	mv	a0,s1
    80001d16:	fffff097          	auipc	ra,0xfffff
    80001d1a:	fd6080e7          	jalr	-42(ra) # 80000cec <release>
    return 0;
    80001d1e:	84ca                	mv	s1,s2
    80001d20:	b7d1                	j	80001ce4 <allocproc+0x90>

0000000080001d22 <userinit>:
{
    80001d22:	1101                	add	sp,sp,-32
    80001d24:	ec06                	sd	ra,24(sp)
    80001d26:	e822                	sd	s0,16(sp)
    80001d28:	e426                	sd	s1,8(sp)
    80001d2a:	1000                	add	s0,sp,32
  p = allocproc();
    80001d2c:	00000097          	auipc	ra,0x0
    80001d30:	f28080e7          	jalr	-216(ra) # 80001c54 <allocproc>
    80001d34:	84aa                	mv	s1,a0
  initproc = p;
    80001d36:	00009797          	auipc	a5,0x9
    80001d3a:	52a7b923          	sd	a0,1330(a5) # 8000b268 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d3e:	03400613          	li	a2,52
    80001d42:	00009597          	auipc	a1,0x9
    80001d46:	4be58593          	add	a1,a1,1214 # 8000b200 <initcode>
    80001d4a:	7528                	ld	a0,104(a0)
    80001d4c:	fffff097          	auipc	ra,0xfffff
    80001d50:	674080e7          	jalr	1652(ra) # 800013c0 <uvmfirst>
  p->sz = PGSIZE;
    80001d54:	6785                	lui	a5,0x1
    80001d56:	f0bc                	sd	a5,96(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d58:	78b8                	ld	a4,112(s1)
    80001d5a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d5e:	78b8                	ld	a4,112(s1)
    80001d60:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d62:	4641                	li	a2,16
    80001d64:	00006597          	auipc	a1,0x6
    80001d68:	48c58593          	add	a1,a1,1164 # 800081f0 <digits+0x1c0>
    80001d6c:	17048513          	add	a0,s1,368
    80001d70:	fffff097          	auipc	ra,0xfffff
    80001d74:	106080e7          	jalr	262(ra) # 80000e76 <safestrcpy>
  p->cwd = namei("/");
    80001d78:	00006517          	auipc	a0,0x6
    80001d7c:	48850513          	add	a0,a0,1160 # 80008200 <digits+0x1d0>
    80001d80:	00002097          	auipc	ra,0x2
    80001d84:	37c080e7          	jalr	892(ra) # 800040fc <namei>
    80001d88:	16a4b423          	sd	a0,360(s1)
  p->state = RUNNABLE;
    80001d8c:	478d                	li	a5,3
    80001d8e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d90:	8526                	mv	a0,s1
    80001d92:	fffff097          	auipc	ra,0xfffff
    80001d96:	f5a080e7          	jalr	-166(ra) # 80000cec <release>
}
    80001d9a:	60e2                	ld	ra,24(sp)
    80001d9c:	6442                	ld	s0,16(sp)
    80001d9e:	64a2                	ld	s1,8(sp)
    80001da0:	6105                	add	sp,sp,32
    80001da2:	8082                	ret

0000000080001da4 <growproc>:
{
    80001da4:	1101                	add	sp,sp,-32
    80001da6:	ec06                	sd	ra,24(sp)
    80001da8:	e822                	sd	s0,16(sp)
    80001daa:	e426                	sd	s1,8(sp)
    80001dac:	e04a                	sd	s2,0(sp)
    80001dae:	1000                	add	s0,sp,32
    80001db0:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001db2:	00000097          	auipc	ra,0x0
    80001db6:	c98080e7          	jalr	-872(ra) # 80001a4a <myproc>
    80001dba:	84aa                	mv	s1,a0
  sz = p->sz;
    80001dbc:	712c                	ld	a1,96(a0)
  if(n > 0){
    80001dbe:	01204c63          	bgtz	s2,80001dd6 <growproc+0x32>
  } else if(n < 0){
    80001dc2:	02094663          	bltz	s2,80001dee <growproc+0x4a>
  p->sz = sz;
    80001dc6:	f0ac                	sd	a1,96(s1)
  return 0;
    80001dc8:	4501                	li	a0,0
}
    80001dca:	60e2                	ld	ra,24(sp)
    80001dcc:	6442                	ld	s0,16(sp)
    80001dce:	64a2                	ld	s1,8(sp)
    80001dd0:	6902                	ld	s2,0(sp)
    80001dd2:	6105                	add	sp,sp,32
    80001dd4:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001dd6:	4691                	li	a3,4
    80001dd8:	00b90633          	add	a2,s2,a1
    80001ddc:	7528                	ld	a0,104(a0)
    80001dde:	fffff097          	auipc	ra,0xfffff
    80001de2:	69c080e7          	jalr	1692(ra) # 8000147a <uvmalloc>
    80001de6:	85aa                	mv	a1,a0
    80001de8:	fd79                	bnez	a0,80001dc6 <growproc+0x22>
      return -1;
    80001dea:	557d                	li	a0,-1
    80001dec:	bff9                	j	80001dca <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dee:	00b90633          	add	a2,s2,a1
    80001df2:	7528                	ld	a0,104(a0)
    80001df4:	fffff097          	auipc	ra,0xfffff
    80001df8:	63e080e7          	jalr	1598(ra) # 80001432 <uvmdealloc>
    80001dfc:	85aa                	mv	a1,a0
    80001dfe:	b7e1                	j	80001dc6 <growproc+0x22>

0000000080001e00 <fork>:
{
    80001e00:	7139                	add	sp,sp,-64
    80001e02:	fc06                	sd	ra,56(sp)
    80001e04:	f822                	sd	s0,48(sp)
    80001e06:	f04a                	sd	s2,32(sp)
    80001e08:	e456                	sd	s5,8(sp)
    80001e0a:	0080                	add	s0,sp,64
  struct proc *p = myproc();
    80001e0c:	00000097          	auipc	ra,0x0
    80001e10:	c3e080e7          	jalr	-962(ra) # 80001a4a <myproc>
    80001e14:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e16:	00000097          	auipc	ra,0x0
    80001e1a:	e3e080e7          	jalr	-450(ra) # 80001c54 <allocproc>
    80001e1e:	12050063          	beqz	a0,80001f3e <fork+0x13e>
    80001e22:	e852                	sd	s4,16(sp)
    80001e24:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e26:	060ab603          	ld	a2,96(s5)
    80001e2a:	752c                	ld	a1,104(a0)
    80001e2c:	068ab503          	ld	a0,104(s5)
    80001e30:	fffff097          	auipc	ra,0xfffff
    80001e34:	7ae080e7          	jalr	1966(ra) # 800015de <uvmcopy>
    80001e38:	04054a63          	bltz	a0,80001e8c <fork+0x8c>
    80001e3c:	f426                	sd	s1,40(sp)
    80001e3e:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001e40:	060ab783          	ld	a5,96(s5)
    80001e44:	06fa3023          	sd	a5,96(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e48:	070ab683          	ld	a3,112(s5)
    80001e4c:	87b6                	mv	a5,a3
    80001e4e:	070a3703          	ld	a4,112(s4)
    80001e52:	12068693          	add	a3,a3,288
    80001e56:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e5a:	6788                	ld	a0,8(a5)
    80001e5c:	6b8c                	ld	a1,16(a5)
    80001e5e:	6f90                	ld	a2,24(a5)
    80001e60:	01073023          	sd	a6,0(a4)
    80001e64:	e708                	sd	a0,8(a4)
    80001e66:	eb0c                	sd	a1,16(a4)
    80001e68:	ef10                	sd	a2,24(a4)
    80001e6a:	02078793          	add	a5,a5,32
    80001e6e:	02070713          	add	a4,a4,32
    80001e72:	fed792e3          	bne	a5,a3,80001e56 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e76:	070a3783          	ld	a5,112(s4)
    80001e7a:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e7e:	0e8a8493          	add	s1,s5,232
    80001e82:	0e8a0913          	add	s2,s4,232
    80001e86:	168a8993          	add	s3,s5,360
    80001e8a:	a015                	j	80001eae <fork+0xae>
    freeproc(np);
    80001e8c:	8552                	mv	a0,s4
    80001e8e:	00000097          	auipc	ra,0x0
    80001e92:	d6e080e7          	jalr	-658(ra) # 80001bfc <freeproc>
    release(&np->lock);
    80001e96:	8552                	mv	a0,s4
    80001e98:	fffff097          	auipc	ra,0xfffff
    80001e9c:	e54080e7          	jalr	-428(ra) # 80000cec <release>
    return -1;
    80001ea0:	597d                	li	s2,-1
    80001ea2:	6a42                	ld	s4,16(sp)
    80001ea4:	a071                	j	80001f30 <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001ea6:	04a1                	add	s1,s1,8
    80001ea8:	0921                	add	s2,s2,8
    80001eaa:	01348b63          	beq	s1,s3,80001ec0 <fork+0xc0>
    if(p->ofile[i])
    80001eae:	6088                	ld	a0,0(s1)
    80001eb0:	d97d                	beqz	a0,80001ea6 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eb2:	00003097          	auipc	ra,0x3
    80001eb6:	8c2080e7          	jalr	-1854(ra) # 80004774 <filedup>
    80001eba:	00a93023          	sd	a0,0(s2)
    80001ebe:	b7e5                	j	80001ea6 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001ec0:	168ab503          	ld	a0,360(s5)
    80001ec4:	00002097          	auipc	ra,0x2
    80001ec8:	a2c080e7          	jalr	-1492(ra) # 800038f0 <idup>
    80001ecc:	16aa3423          	sd	a0,360(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ed0:	4641                	li	a2,16
    80001ed2:	170a8593          	add	a1,s5,368
    80001ed6:	170a0513          	add	a0,s4,368
    80001eda:	fffff097          	auipc	ra,0xfffff
    80001ede:	f9c080e7          	jalr	-100(ra) # 80000e76 <safestrcpy>
  pid = np->pid;
    80001ee2:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001ee6:	8552                	mv	a0,s4
    80001ee8:	fffff097          	auipc	ra,0xfffff
    80001eec:	e04080e7          	jalr	-508(ra) # 80000cec <release>
  acquire(&wait_lock);
    80001ef0:	00011497          	auipc	s1,0x11
    80001ef4:	60848493          	add	s1,s1,1544 # 800134f8 <wait_lock>
    80001ef8:	8526                	mv	a0,s1
    80001efa:	fffff097          	auipc	ra,0xfffff
    80001efe:	d3e080e7          	jalr	-706(ra) # 80000c38 <acquire>
  np->parent = p;
    80001f02:	055a3823          	sd	s5,80(s4)
  release(&wait_lock);
    80001f06:	8526                	mv	a0,s1
    80001f08:	fffff097          	auipc	ra,0xfffff
    80001f0c:	de4080e7          	jalr	-540(ra) # 80000cec <release>
  acquire(&np->lock);
    80001f10:	8552                	mv	a0,s4
    80001f12:	fffff097          	auipc	ra,0xfffff
    80001f16:	d26080e7          	jalr	-730(ra) # 80000c38 <acquire>
  np->state = RUNNABLE;
    80001f1a:	478d                	li	a5,3
    80001f1c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f20:	8552                	mv	a0,s4
    80001f22:	fffff097          	auipc	ra,0xfffff
    80001f26:	dca080e7          	jalr	-566(ra) # 80000cec <release>
  return pid;
    80001f2a:	74a2                	ld	s1,40(sp)
    80001f2c:	69e2                	ld	s3,24(sp)
    80001f2e:	6a42                	ld	s4,16(sp)
}
    80001f30:	854a                	mv	a0,s2
    80001f32:	70e2                	ld	ra,56(sp)
    80001f34:	7442                	ld	s0,48(sp)
    80001f36:	7902                	ld	s2,32(sp)
    80001f38:	6aa2                	ld	s5,8(sp)
    80001f3a:	6121                	add	sp,sp,64
    80001f3c:	8082                	ret
    return -1;
    80001f3e:	597d                	li	s2,-1
    80001f40:	bfc5                	j	80001f30 <fork+0x130>

0000000080001f42 <scheduler>:
{
    80001f42:	7139                	add	sp,sp,-64
    80001f44:	fc06                	sd	ra,56(sp)
    80001f46:	f822                	sd	s0,48(sp)
    80001f48:	f426                	sd	s1,40(sp)
    80001f4a:	f04a                	sd	s2,32(sp)
    80001f4c:	ec4e                	sd	s3,24(sp)
    80001f4e:	e852                	sd	s4,16(sp)
    80001f50:	e456                	sd	s5,8(sp)
    80001f52:	e05a                	sd	s6,0(sp)
    80001f54:	0080                	add	s0,sp,64
    80001f56:	8792                	mv	a5,tp
  int id = r_tp();
    80001f58:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f5a:	00779a93          	sll	s5,a5,0x7
    80001f5e:	00011717          	auipc	a4,0x11
    80001f62:	58270713          	add	a4,a4,1410 # 800134e0 <pid_lock>
    80001f66:	9756                	add	a4,a4,s5
    80001f68:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f6c:	00011717          	auipc	a4,0x11
    80001f70:	5ac70713          	add	a4,a4,1452 # 80013518 <cpus+0x8>
    80001f74:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001f76:	498d                	li	s3,3
        p->state = RUNNING;
    80001f78:	4b11                	li	s6,4
        c->proc = p;
    80001f7a:	079e                	sll	a5,a5,0x7
    80001f7c:	00011a17          	auipc	s4,0x11
    80001f80:	564a0a13          	add	s4,s4,1380 # 800134e0 <pid_lock>
    80001f84:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f86:	00018917          	auipc	s2,0x18
    80001f8a:	98a90913          	add	s2,s2,-1654 # 80019910 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f8e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f92:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f96:	10079073          	csrw	sstatus,a5
    80001f9a:	00012497          	auipc	s1,0x12
    80001f9e:	97648493          	add	s1,s1,-1674 # 80013910 <proc>
    80001fa2:	a811                	j	80001fb6 <scheduler+0x74>
      release(&p->lock);
    80001fa4:	8526                	mv	a0,s1
    80001fa6:	fffff097          	auipc	ra,0xfffff
    80001faa:	d46080e7          	jalr	-698(ra) # 80000cec <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fae:	18048493          	add	s1,s1,384
    80001fb2:	fd248ee3          	beq	s1,s2,80001f8e <scheduler+0x4c>
      acquire(&p->lock);
    80001fb6:	8526                	mv	a0,s1
    80001fb8:	fffff097          	auipc	ra,0xfffff
    80001fbc:	c80080e7          	jalr	-896(ra) # 80000c38 <acquire>
      if(p->state == RUNNABLE) {
    80001fc0:	4c9c                	lw	a5,24(s1)
    80001fc2:	ff3791e3          	bne	a5,s3,80001fa4 <scheduler+0x62>
        p->state = RUNNING;
    80001fc6:	0164ac23          	sw	s6,24(s1)
        p->runCount++; //Incrementing the run counter here
    80001fca:	58dc                	lw	a5,52(s1)
    80001fcc:	2785                	addw	a5,a5,1
    80001fce:	d8dc                	sw	a5,52(s1)
        c->proc = p;
    80001fd0:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fd4:	07848593          	add	a1,s1,120
    80001fd8:	8556                	mv	a0,s5
    80001fda:	00000097          	auipc	ra,0x0
    80001fde:	690080e7          	jalr	1680(ra) # 8000266a <swtch>
        c->proc = 0;
    80001fe2:	020a3823          	sd	zero,48(s4)
    80001fe6:	bf7d                	j	80001fa4 <scheduler+0x62>

0000000080001fe8 <sched>:
{
    80001fe8:	7179                	add	sp,sp,-48
    80001fea:	f406                	sd	ra,40(sp)
    80001fec:	f022                	sd	s0,32(sp)
    80001fee:	ec26                	sd	s1,24(sp)
    80001ff0:	e84a                	sd	s2,16(sp)
    80001ff2:	e44e                	sd	s3,8(sp)
    80001ff4:	1800                	add	s0,sp,48
  struct proc *p = myproc();
    80001ff6:	00000097          	auipc	ra,0x0
    80001ffa:	a54080e7          	jalr	-1452(ra) # 80001a4a <myproc>
    80001ffe:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002000:	fffff097          	auipc	ra,0xfffff
    80002004:	bbe080e7          	jalr	-1090(ra) # 80000bbe <holding>
    80002008:	c93d                	beqz	a0,8000207e <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000200a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000200c:	2781                	sext.w	a5,a5
    8000200e:	079e                	sll	a5,a5,0x7
    80002010:	00011717          	auipc	a4,0x11
    80002014:	4d070713          	add	a4,a4,1232 # 800134e0 <pid_lock>
    80002018:	97ba                	add	a5,a5,a4
    8000201a:	0a87a703          	lw	a4,168(a5)
    8000201e:	4785                	li	a5,1
    80002020:	06f71763          	bne	a4,a5,8000208e <sched+0xa6>
  if(p->state == RUNNING)
    80002024:	4c98                	lw	a4,24(s1)
    80002026:	4791                	li	a5,4
    80002028:	06f70b63          	beq	a4,a5,8000209e <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000202c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002030:	8b89                	and	a5,a5,2
  if(intr_get())
    80002032:	efb5                	bnez	a5,800020ae <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002034:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002036:	00011917          	auipc	s2,0x11
    8000203a:	4aa90913          	add	s2,s2,1194 # 800134e0 <pid_lock>
    8000203e:	2781                	sext.w	a5,a5
    80002040:	079e                	sll	a5,a5,0x7
    80002042:	97ca                	add	a5,a5,s2
    80002044:	0ac7a983          	lw	s3,172(a5)
    80002048:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000204a:	2781                	sext.w	a5,a5
    8000204c:	079e                	sll	a5,a5,0x7
    8000204e:	00011597          	auipc	a1,0x11
    80002052:	4ca58593          	add	a1,a1,1226 # 80013518 <cpus+0x8>
    80002056:	95be                	add	a1,a1,a5
    80002058:	07848513          	add	a0,s1,120
    8000205c:	00000097          	auipc	ra,0x0
    80002060:	60e080e7          	jalr	1550(ra) # 8000266a <swtch>
    80002064:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002066:	2781                	sext.w	a5,a5
    80002068:	079e                	sll	a5,a5,0x7
    8000206a:	993e                	add	s2,s2,a5
    8000206c:	0b392623          	sw	s3,172(s2)
}
    80002070:	70a2                	ld	ra,40(sp)
    80002072:	7402                	ld	s0,32(sp)
    80002074:	64e2                	ld	s1,24(sp)
    80002076:	6942                	ld	s2,16(sp)
    80002078:	69a2                	ld	s3,8(sp)
    8000207a:	6145                	add	sp,sp,48
    8000207c:	8082                	ret
    panic("sched p->lock");
    8000207e:	00006517          	auipc	a0,0x6
    80002082:	18a50513          	add	a0,a0,394 # 80008208 <digits+0x1d8>
    80002086:	ffffe097          	auipc	ra,0xffffe
    8000208a:	4da080e7          	jalr	1242(ra) # 80000560 <panic>
    panic("sched locks");
    8000208e:	00006517          	auipc	a0,0x6
    80002092:	18a50513          	add	a0,a0,394 # 80008218 <digits+0x1e8>
    80002096:	ffffe097          	auipc	ra,0xffffe
    8000209a:	4ca080e7          	jalr	1226(ra) # 80000560 <panic>
    panic("sched running");
    8000209e:	00006517          	auipc	a0,0x6
    800020a2:	18a50513          	add	a0,a0,394 # 80008228 <digits+0x1f8>
    800020a6:	ffffe097          	auipc	ra,0xffffe
    800020aa:	4ba080e7          	jalr	1210(ra) # 80000560 <panic>
    panic("sched interruptible");
    800020ae:	00006517          	auipc	a0,0x6
    800020b2:	18a50513          	add	a0,a0,394 # 80008238 <digits+0x208>
    800020b6:	ffffe097          	auipc	ra,0xffffe
    800020ba:	4aa080e7          	jalr	1194(ra) # 80000560 <panic>

00000000800020be <yield>:
{
    800020be:	1101                	add	sp,sp,-32
    800020c0:	ec06                	sd	ra,24(sp)
    800020c2:	e822                	sd	s0,16(sp)
    800020c4:	e426                	sd	s1,8(sp)
    800020c6:	1000                	add	s0,sp,32
  struct proc *p = myproc();
    800020c8:	00000097          	auipc	ra,0x0
    800020cc:	982080e7          	jalr	-1662(ra) # 80001a4a <myproc>
    800020d0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020d2:	fffff097          	auipc	ra,0xfffff
    800020d6:	b66080e7          	jalr	-1178(ra) # 80000c38 <acquire>
  p->state = RUNNABLE;
    800020da:	478d                	li	a5,3
    800020dc:	cc9c                	sw	a5,24(s1)
  p->preemptCount++; //Incrementing preemptions counter
    800020de:	40bc                	lw	a5,64(s1)
    800020e0:	2785                	addw	a5,a5,1
    800020e2:	c0bc                	sw	a5,64(s1)
  sched();
    800020e4:	00000097          	auipc	ra,0x0
    800020e8:	f04080e7          	jalr	-252(ra) # 80001fe8 <sched>
  release(&p->lock);
    800020ec:	8526                	mv	a0,s1
    800020ee:	fffff097          	auipc	ra,0xfffff
    800020f2:	bfe080e7          	jalr	-1026(ra) # 80000cec <release>
}
    800020f6:	60e2                	ld	ra,24(sp)
    800020f8:	6442                	ld	s0,16(sp)
    800020fa:	64a2                	ld	s1,8(sp)
    800020fc:	6105                	add	sp,sp,32
    800020fe:	8082                	ret

0000000080002100 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002100:	7179                	add	sp,sp,-48
    80002102:	f406                	sd	ra,40(sp)
    80002104:	f022                	sd	s0,32(sp)
    80002106:	ec26                	sd	s1,24(sp)
    80002108:	e84a                	sd	s2,16(sp)
    8000210a:	e44e                	sd	s3,8(sp)
    8000210c:	1800                	add	s0,sp,48
    8000210e:	89aa                	mv	s3,a0
    80002110:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002112:	00000097          	auipc	ra,0x0
    80002116:	938080e7          	jalr	-1736(ra) # 80001a4a <myproc>
    8000211a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000211c:	fffff097          	auipc	ra,0xfffff
    80002120:	b1c080e7          	jalr	-1252(ra) # 80000c38 <acquire>
  release(lk);
    80002124:	854a                	mv	a0,s2
    80002126:	fffff097          	auipc	ra,0xfffff
    8000212a:	bc6080e7          	jalr	-1082(ra) # 80000cec <release>
  p->sleepCount++;  //Changed this to increment the sleep counter right before going to sleep
    8000212e:	44bc                	lw	a5,72(s1)
    80002130:	2785                	addw	a5,a5,1
    80002132:	c4bc                	sw	a5,72(s1)
  // Go to sleep.
  p->chan = chan;
    80002134:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002138:	4789                	li	a5,2
    8000213a:	cc9c                	sw	a5,24(s1)

  sched();
    8000213c:	00000097          	auipc	ra,0x0
    80002140:	eac080e7          	jalr	-340(ra) # 80001fe8 <sched>

  // Tidy up.
  p->chan = 0;
    80002144:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002148:	8526                	mv	a0,s1
    8000214a:	fffff097          	auipc	ra,0xfffff
    8000214e:	ba2080e7          	jalr	-1118(ra) # 80000cec <release>
  acquire(lk);
    80002152:	854a                	mv	a0,s2
    80002154:	fffff097          	auipc	ra,0xfffff
    80002158:	ae4080e7          	jalr	-1308(ra) # 80000c38 <acquire>
}
    8000215c:	70a2                	ld	ra,40(sp)
    8000215e:	7402                	ld	s0,32(sp)
    80002160:	64e2                	ld	s1,24(sp)
    80002162:	6942                	ld	s2,16(sp)
    80002164:	69a2                	ld	s3,8(sp)
    80002166:	6145                	add	sp,sp,48
    80002168:	8082                	ret

000000008000216a <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000216a:	7139                	add	sp,sp,-64
    8000216c:	fc06                	sd	ra,56(sp)
    8000216e:	f822                	sd	s0,48(sp)
    80002170:	f426                	sd	s1,40(sp)
    80002172:	f04a                	sd	s2,32(sp)
    80002174:	ec4e                	sd	s3,24(sp)
    80002176:	e852                	sd	s4,16(sp)
    80002178:	e456                	sd	s5,8(sp)
    8000217a:	0080                	add	s0,sp,64
    8000217c:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000217e:	00011497          	auipc	s1,0x11
    80002182:	79248493          	add	s1,s1,1938 # 80013910 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002186:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002188:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000218a:	00017917          	auipc	s2,0x17
    8000218e:	78690913          	add	s2,s2,1926 # 80019910 <tickslock>
    80002192:	a811                	j	800021a6 <wakeup+0x3c>
      }
      release(&p->lock);
    80002194:	8526                	mv	a0,s1
    80002196:	fffff097          	auipc	ra,0xfffff
    8000219a:	b56080e7          	jalr	-1194(ra) # 80000cec <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000219e:	18048493          	add	s1,s1,384
    800021a2:	03248663          	beq	s1,s2,800021ce <wakeup+0x64>
    if(p != myproc()){
    800021a6:	00000097          	auipc	ra,0x0
    800021aa:	8a4080e7          	jalr	-1884(ra) # 80001a4a <myproc>
    800021ae:	fea488e3          	beq	s1,a0,8000219e <wakeup+0x34>
      acquire(&p->lock);
    800021b2:	8526                	mv	a0,s1
    800021b4:	fffff097          	auipc	ra,0xfffff
    800021b8:	a84080e7          	jalr	-1404(ra) # 80000c38 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800021bc:	4c9c                	lw	a5,24(s1)
    800021be:	fd379be3          	bne	a5,s3,80002194 <wakeup+0x2a>
    800021c2:	709c                	ld	a5,32(s1)
    800021c4:	fd4798e3          	bne	a5,s4,80002194 <wakeup+0x2a>
        p->state = RUNNABLE;
    800021c8:	0154ac23          	sw	s5,24(s1)
    800021cc:	b7e1                	j	80002194 <wakeup+0x2a>
    }
  }
}
    800021ce:	70e2                	ld	ra,56(sp)
    800021d0:	7442                	ld	s0,48(sp)
    800021d2:	74a2                	ld	s1,40(sp)
    800021d4:	7902                	ld	s2,32(sp)
    800021d6:	69e2                	ld	s3,24(sp)
    800021d8:	6a42                	ld	s4,16(sp)
    800021da:	6aa2                	ld	s5,8(sp)
    800021dc:	6121                	add	sp,sp,64
    800021de:	8082                	ret

00000000800021e0 <reparent>:
{
    800021e0:	7179                	add	sp,sp,-48
    800021e2:	f406                	sd	ra,40(sp)
    800021e4:	f022                	sd	s0,32(sp)
    800021e6:	ec26                	sd	s1,24(sp)
    800021e8:	e84a                	sd	s2,16(sp)
    800021ea:	e44e                	sd	s3,8(sp)
    800021ec:	e052                	sd	s4,0(sp)
    800021ee:	1800                	add	s0,sp,48
    800021f0:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021f2:	00011497          	auipc	s1,0x11
    800021f6:	71e48493          	add	s1,s1,1822 # 80013910 <proc>
      pp->parent = initproc;
    800021fa:	00009a17          	auipc	s4,0x9
    800021fe:	06ea0a13          	add	s4,s4,110 # 8000b268 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002202:	00017997          	auipc	s3,0x17
    80002206:	70e98993          	add	s3,s3,1806 # 80019910 <tickslock>
    8000220a:	a029                	j	80002214 <reparent+0x34>
    8000220c:	18048493          	add	s1,s1,384
    80002210:	01348d63          	beq	s1,s3,8000222a <reparent+0x4a>
    if(pp->parent == p){
    80002214:	68bc                	ld	a5,80(s1)
    80002216:	ff279be3          	bne	a5,s2,8000220c <reparent+0x2c>
      pp->parent = initproc;
    8000221a:	000a3503          	ld	a0,0(s4)
    8000221e:	e8a8                	sd	a0,80(s1)
      wakeup(initproc);
    80002220:	00000097          	auipc	ra,0x0
    80002224:	f4a080e7          	jalr	-182(ra) # 8000216a <wakeup>
    80002228:	b7d5                	j	8000220c <reparent+0x2c>
}
    8000222a:	70a2                	ld	ra,40(sp)
    8000222c:	7402                	ld	s0,32(sp)
    8000222e:	64e2                	ld	s1,24(sp)
    80002230:	6942                	ld	s2,16(sp)
    80002232:	69a2                	ld	s3,8(sp)
    80002234:	6a02                	ld	s4,0(sp)
    80002236:	6145                	add	sp,sp,48
    80002238:	8082                	ret

000000008000223a <exit>:
{
    8000223a:	7179                	add	sp,sp,-48
    8000223c:	f406                	sd	ra,40(sp)
    8000223e:	f022                	sd	s0,32(sp)
    80002240:	ec26                	sd	s1,24(sp)
    80002242:	e84a                	sd	s2,16(sp)
    80002244:	e44e                	sd	s3,8(sp)
    80002246:	e052                	sd	s4,0(sp)
    80002248:	1800                	add	s0,sp,48
    8000224a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000224c:	fffff097          	auipc	ra,0xfffff
    80002250:	7fe080e7          	jalr	2046(ra) # 80001a4a <myproc>
    80002254:	89aa                	mv	s3,a0
  if(p == initproc)
    80002256:	00009797          	auipc	a5,0x9
    8000225a:	0127b783          	ld	a5,18(a5) # 8000b268 <initproc>
    8000225e:	0e850493          	add	s1,a0,232
    80002262:	16850913          	add	s2,a0,360
    80002266:	02a79363          	bne	a5,a0,8000228c <exit+0x52>
    panic("init exiting");
    8000226a:	00006517          	auipc	a0,0x6
    8000226e:	fe650513          	add	a0,a0,-26 # 80008250 <digits+0x220>
    80002272:	ffffe097          	auipc	ra,0xffffe
    80002276:	2ee080e7          	jalr	750(ra) # 80000560 <panic>
      fileclose(f);
    8000227a:	00002097          	auipc	ra,0x2
    8000227e:	54c080e7          	jalr	1356(ra) # 800047c6 <fileclose>
      p->ofile[fd] = 0;
    80002282:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002286:	04a1                	add	s1,s1,8
    80002288:	01248563          	beq	s1,s2,80002292 <exit+0x58>
    if(p->ofile[fd]){
    8000228c:	6088                	ld	a0,0(s1)
    8000228e:	f575                	bnez	a0,8000227a <exit+0x40>
    80002290:	bfdd                	j	80002286 <exit+0x4c>
  begin_op();
    80002292:	00002097          	auipc	ra,0x2
    80002296:	06a080e7          	jalr	106(ra) # 800042fc <begin_op>
  iput(p->cwd);
    8000229a:	1689b503          	ld	a0,360(s3)
    8000229e:	00002097          	auipc	ra,0x2
    800022a2:	84e080e7          	jalr	-1970(ra) # 80003aec <iput>
  end_op();
    800022a6:	00002097          	auipc	ra,0x2
    800022aa:	0d0080e7          	jalr	208(ra) # 80004376 <end_op>
  p->cwd = 0;
    800022ae:	1609b423          	sd	zero,360(s3)
  acquire(&wait_lock);
    800022b2:	00011497          	auipc	s1,0x11
    800022b6:	24648493          	add	s1,s1,582 # 800134f8 <wait_lock>
    800022ba:	8526                	mv	a0,s1
    800022bc:	fffff097          	auipc	ra,0xfffff
    800022c0:	97c080e7          	jalr	-1668(ra) # 80000c38 <acquire>
  reparent(p);
    800022c4:	854e                	mv	a0,s3
    800022c6:	00000097          	auipc	ra,0x0
    800022ca:	f1a080e7          	jalr	-230(ra) # 800021e0 <reparent>
  wakeup(p->parent);
    800022ce:	0509b503          	ld	a0,80(s3)
    800022d2:	00000097          	auipc	ra,0x0
    800022d6:	e98080e7          	jalr	-360(ra) # 8000216a <wakeup>
  acquire(&p->lock);
    800022da:	854e                	mv	a0,s3
    800022dc:	fffff097          	auipc	ra,0xfffff
    800022e0:	95c080e7          	jalr	-1700(ra) # 80000c38 <acquire>
  p->xstate = status;
    800022e4:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022e8:	4795                	li	a5,5
    800022ea:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022ee:	8526                	mv	a0,s1
    800022f0:	fffff097          	auipc	ra,0xfffff
    800022f4:	9fc080e7          	jalr	-1540(ra) # 80000cec <release>
  sched();
    800022f8:	00000097          	auipc	ra,0x0
    800022fc:	cf0080e7          	jalr	-784(ra) # 80001fe8 <sched>
  panic("zombie exit");
    80002300:	00006517          	auipc	a0,0x6
    80002304:	f6050513          	add	a0,a0,-160 # 80008260 <digits+0x230>
    80002308:	ffffe097          	auipc	ra,0xffffe
    8000230c:	258080e7          	jalr	600(ra) # 80000560 <panic>

0000000080002310 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002310:	7179                	add	sp,sp,-48
    80002312:	f406                	sd	ra,40(sp)
    80002314:	f022                	sd	s0,32(sp)
    80002316:	ec26                	sd	s1,24(sp)
    80002318:	e84a                	sd	s2,16(sp)
    8000231a:	e44e                	sd	s3,8(sp)
    8000231c:	1800                	add	s0,sp,48
    8000231e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002320:	00011497          	auipc	s1,0x11
    80002324:	5f048493          	add	s1,s1,1520 # 80013910 <proc>
    80002328:	00017997          	auipc	s3,0x17
    8000232c:	5e898993          	add	s3,s3,1512 # 80019910 <tickslock>
    acquire(&p->lock);
    80002330:	8526                	mv	a0,s1
    80002332:	fffff097          	auipc	ra,0xfffff
    80002336:	906080e7          	jalr	-1786(ra) # 80000c38 <acquire>
    if(p->pid == pid){
    8000233a:	589c                	lw	a5,48(s1)
    8000233c:	01278d63          	beq	a5,s2,80002356 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002340:	8526                	mv	a0,s1
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	9aa080e7          	jalr	-1622(ra) # 80000cec <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000234a:	18048493          	add	s1,s1,384
    8000234e:	ff3491e3          	bne	s1,s3,80002330 <kill+0x20>
  }
  return -1;
    80002352:	557d                	li	a0,-1
    80002354:	a829                	j	8000236e <kill+0x5e>
      p->killed = 1;
    80002356:	4785                	li	a5,1
    80002358:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000235a:	4c98                	lw	a4,24(s1)
    8000235c:	4789                	li	a5,2
    8000235e:	00f70f63          	beq	a4,a5,8000237c <kill+0x6c>
      release(&p->lock);
    80002362:	8526                	mv	a0,s1
    80002364:	fffff097          	auipc	ra,0xfffff
    80002368:	988080e7          	jalr	-1656(ra) # 80000cec <release>
      return 0;
    8000236c:	4501                	li	a0,0
}
    8000236e:	70a2                	ld	ra,40(sp)
    80002370:	7402                	ld	s0,32(sp)
    80002372:	64e2                	ld	s1,24(sp)
    80002374:	6942                	ld	s2,16(sp)
    80002376:	69a2                	ld	s3,8(sp)
    80002378:	6145                	add	sp,sp,48
    8000237a:	8082                	ret
        p->state = RUNNABLE;
    8000237c:	478d                	li	a5,3
    8000237e:	cc9c                	sw	a5,24(s1)
    80002380:	b7cd                	j	80002362 <kill+0x52>

0000000080002382 <setkilled>:

void
setkilled(struct proc *p)
{
    80002382:	1101                	add	sp,sp,-32
    80002384:	ec06                	sd	ra,24(sp)
    80002386:	e822                	sd	s0,16(sp)
    80002388:	e426                	sd	s1,8(sp)
    8000238a:	1000                	add	s0,sp,32
    8000238c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000238e:	fffff097          	auipc	ra,0xfffff
    80002392:	8aa080e7          	jalr	-1878(ra) # 80000c38 <acquire>
  p->killed = 1;
    80002396:	4785                	li	a5,1
    80002398:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000239a:	8526                	mv	a0,s1
    8000239c:	fffff097          	auipc	ra,0xfffff
    800023a0:	950080e7          	jalr	-1712(ra) # 80000cec <release>
}
    800023a4:	60e2                	ld	ra,24(sp)
    800023a6:	6442                	ld	s0,16(sp)
    800023a8:	64a2                	ld	s1,8(sp)
    800023aa:	6105                	add	sp,sp,32
    800023ac:	8082                	ret

00000000800023ae <killed>:

int
killed(struct proc *p)
{
    800023ae:	1101                	add	sp,sp,-32
    800023b0:	ec06                	sd	ra,24(sp)
    800023b2:	e822                	sd	s0,16(sp)
    800023b4:	e426                	sd	s1,8(sp)
    800023b6:	e04a                	sd	s2,0(sp)
    800023b8:	1000                	add	s0,sp,32
    800023ba:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800023bc:	fffff097          	auipc	ra,0xfffff
    800023c0:	87c080e7          	jalr	-1924(ra) # 80000c38 <acquire>
  k = p->killed;
    800023c4:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800023c8:	8526                	mv	a0,s1
    800023ca:	fffff097          	auipc	ra,0xfffff
    800023ce:	922080e7          	jalr	-1758(ra) # 80000cec <release>
  return k;
}
    800023d2:	854a                	mv	a0,s2
    800023d4:	60e2                	ld	ra,24(sp)
    800023d6:	6442                	ld	s0,16(sp)
    800023d8:	64a2                	ld	s1,8(sp)
    800023da:	6902                	ld	s2,0(sp)
    800023dc:	6105                	add	sp,sp,32
    800023de:	8082                	ret

00000000800023e0 <wait>:
{
    800023e0:	715d                	add	sp,sp,-80
    800023e2:	e486                	sd	ra,72(sp)
    800023e4:	e0a2                	sd	s0,64(sp)
    800023e6:	fc26                	sd	s1,56(sp)
    800023e8:	f84a                	sd	s2,48(sp)
    800023ea:	f44e                	sd	s3,40(sp)
    800023ec:	f052                	sd	s4,32(sp)
    800023ee:	ec56                	sd	s5,24(sp)
    800023f0:	e85a                	sd	s6,16(sp)
    800023f2:	e45e                	sd	s7,8(sp)
    800023f4:	e062                	sd	s8,0(sp)
    800023f6:	0880                	add	s0,sp,80
    800023f8:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023fa:	fffff097          	auipc	ra,0xfffff
    800023fe:	650080e7          	jalr	1616(ra) # 80001a4a <myproc>
    80002402:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002404:	00011517          	auipc	a0,0x11
    80002408:	0f450513          	add	a0,a0,244 # 800134f8 <wait_lock>
    8000240c:	fffff097          	auipc	ra,0xfffff
    80002410:	82c080e7          	jalr	-2004(ra) # 80000c38 <acquire>
    havekids = 0;
    80002414:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002416:	4a15                	li	s4,5
        havekids = 1;
    80002418:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000241a:	00017997          	auipc	s3,0x17
    8000241e:	4f698993          	add	s3,s3,1270 # 80019910 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002422:	00011c17          	auipc	s8,0x11
    80002426:	0d6c0c13          	add	s8,s8,214 # 800134f8 <wait_lock>
    8000242a:	a0d1                	j	800024ee <wait+0x10e>
          pid = pp->pid;
    8000242c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002430:	000b0e63          	beqz	s6,8000244c <wait+0x6c>
    80002434:	4691                	li	a3,4
    80002436:	02c48613          	add	a2,s1,44
    8000243a:	85da                	mv	a1,s6
    8000243c:	06893503          	ld	a0,104(s2)
    80002440:	fffff097          	auipc	ra,0xfffff
    80002444:	2a2080e7          	jalr	674(ra) # 800016e2 <copyout>
    80002448:	04054163          	bltz	a0,8000248a <wait+0xaa>
          freeproc(pp);
    8000244c:	8526                	mv	a0,s1
    8000244e:	fffff097          	auipc	ra,0xfffff
    80002452:	7ae080e7          	jalr	1966(ra) # 80001bfc <freeproc>
          release(&pp->lock);
    80002456:	8526                	mv	a0,s1
    80002458:	fffff097          	auipc	ra,0xfffff
    8000245c:	894080e7          	jalr	-1900(ra) # 80000cec <release>
          release(&wait_lock);
    80002460:	00011517          	auipc	a0,0x11
    80002464:	09850513          	add	a0,a0,152 # 800134f8 <wait_lock>
    80002468:	fffff097          	auipc	ra,0xfffff
    8000246c:	884080e7          	jalr	-1916(ra) # 80000cec <release>
}
    80002470:	854e                	mv	a0,s3
    80002472:	60a6                	ld	ra,72(sp)
    80002474:	6406                	ld	s0,64(sp)
    80002476:	74e2                	ld	s1,56(sp)
    80002478:	7942                	ld	s2,48(sp)
    8000247a:	79a2                	ld	s3,40(sp)
    8000247c:	7a02                	ld	s4,32(sp)
    8000247e:	6ae2                	ld	s5,24(sp)
    80002480:	6b42                	ld	s6,16(sp)
    80002482:	6ba2                	ld	s7,8(sp)
    80002484:	6c02                	ld	s8,0(sp)
    80002486:	6161                	add	sp,sp,80
    80002488:	8082                	ret
            release(&pp->lock);
    8000248a:	8526                	mv	a0,s1
    8000248c:	fffff097          	auipc	ra,0xfffff
    80002490:	860080e7          	jalr	-1952(ra) # 80000cec <release>
            release(&wait_lock);
    80002494:	00011517          	auipc	a0,0x11
    80002498:	06450513          	add	a0,a0,100 # 800134f8 <wait_lock>
    8000249c:	fffff097          	auipc	ra,0xfffff
    800024a0:	850080e7          	jalr	-1968(ra) # 80000cec <release>
            return -1;
    800024a4:	59fd                	li	s3,-1
    800024a6:	b7e9                	j	80002470 <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024a8:	18048493          	add	s1,s1,384
    800024ac:	03348463          	beq	s1,s3,800024d4 <wait+0xf4>
      if(pp->parent == p){
    800024b0:	68bc                	ld	a5,80(s1)
    800024b2:	ff279be3          	bne	a5,s2,800024a8 <wait+0xc8>
        acquire(&pp->lock);
    800024b6:	8526                	mv	a0,s1
    800024b8:	ffffe097          	auipc	ra,0xffffe
    800024bc:	780080e7          	jalr	1920(ra) # 80000c38 <acquire>
        if(pp->state == ZOMBIE){
    800024c0:	4c9c                	lw	a5,24(s1)
    800024c2:	f74785e3          	beq	a5,s4,8000242c <wait+0x4c>
        release(&pp->lock);
    800024c6:	8526                	mv	a0,s1
    800024c8:	fffff097          	auipc	ra,0xfffff
    800024cc:	824080e7          	jalr	-2012(ra) # 80000cec <release>
        havekids = 1;
    800024d0:	8756                	mv	a4,s5
    800024d2:	bfd9                	j	800024a8 <wait+0xc8>
    if(!havekids || killed(p)){
    800024d4:	c31d                	beqz	a4,800024fa <wait+0x11a>
    800024d6:	854a                	mv	a0,s2
    800024d8:	00000097          	auipc	ra,0x0
    800024dc:	ed6080e7          	jalr	-298(ra) # 800023ae <killed>
    800024e0:	ed09                	bnez	a0,800024fa <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024e2:	85e2                	mv	a1,s8
    800024e4:	854a                	mv	a0,s2
    800024e6:	00000097          	auipc	ra,0x0
    800024ea:	c1a080e7          	jalr	-998(ra) # 80002100 <sleep>
    havekids = 0;
    800024ee:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024f0:	00011497          	auipc	s1,0x11
    800024f4:	42048493          	add	s1,s1,1056 # 80013910 <proc>
    800024f8:	bf65                	j	800024b0 <wait+0xd0>
      release(&wait_lock);
    800024fa:	00011517          	auipc	a0,0x11
    800024fe:	ffe50513          	add	a0,a0,-2 # 800134f8 <wait_lock>
    80002502:	ffffe097          	auipc	ra,0xffffe
    80002506:	7ea080e7          	jalr	2026(ra) # 80000cec <release>
      return -1;
    8000250a:	59fd                	li	s3,-1
    8000250c:	b795                	j	80002470 <wait+0x90>

000000008000250e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000250e:	7179                	add	sp,sp,-48
    80002510:	f406                	sd	ra,40(sp)
    80002512:	f022                	sd	s0,32(sp)
    80002514:	ec26                	sd	s1,24(sp)
    80002516:	e84a                	sd	s2,16(sp)
    80002518:	e44e                	sd	s3,8(sp)
    8000251a:	e052                	sd	s4,0(sp)
    8000251c:	1800                	add	s0,sp,48
    8000251e:	84aa                	mv	s1,a0
    80002520:	892e                	mv	s2,a1
    80002522:	89b2                	mv	s3,a2
    80002524:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002526:	fffff097          	auipc	ra,0xfffff
    8000252a:	524080e7          	jalr	1316(ra) # 80001a4a <myproc>
  if(user_dst){
    8000252e:	c08d                	beqz	s1,80002550 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002530:	86d2                	mv	a3,s4
    80002532:	864e                	mv	a2,s3
    80002534:	85ca                	mv	a1,s2
    80002536:	7528                	ld	a0,104(a0)
    80002538:	fffff097          	auipc	ra,0xfffff
    8000253c:	1aa080e7          	jalr	426(ra) # 800016e2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002540:	70a2                	ld	ra,40(sp)
    80002542:	7402                	ld	s0,32(sp)
    80002544:	64e2                	ld	s1,24(sp)
    80002546:	6942                	ld	s2,16(sp)
    80002548:	69a2                	ld	s3,8(sp)
    8000254a:	6a02                	ld	s4,0(sp)
    8000254c:	6145                	add	sp,sp,48
    8000254e:	8082                	ret
    memmove((char *)dst, src, len);
    80002550:	000a061b          	sext.w	a2,s4
    80002554:	85ce                	mv	a1,s3
    80002556:	854a                	mv	a0,s2
    80002558:	fffff097          	auipc	ra,0xfffff
    8000255c:	838080e7          	jalr	-1992(ra) # 80000d90 <memmove>
    return 0;
    80002560:	8526                	mv	a0,s1
    80002562:	bff9                	j	80002540 <either_copyout+0x32>

0000000080002564 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002564:	7179                	add	sp,sp,-48
    80002566:	f406                	sd	ra,40(sp)
    80002568:	f022                	sd	s0,32(sp)
    8000256a:	ec26                	sd	s1,24(sp)
    8000256c:	e84a                	sd	s2,16(sp)
    8000256e:	e44e                	sd	s3,8(sp)
    80002570:	e052                	sd	s4,0(sp)
    80002572:	1800                	add	s0,sp,48
    80002574:	892a                	mv	s2,a0
    80002576:	84ae                	mv	s1,a1
    80002578:	89b2                	mv	s3,a2
    8000257a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000257c:	fffff097          	auipc	ra,0xfffff
    80002580:	4ce080e7          	jalr	1230(ra) # 80001a4a <myproc>
  if(user_src){
    80002584:	c08d                	beqz	s1,800025a6 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002586:	86d2                	mv	a3,s4
    80002588:	864e                	mv	a2,s3
    8000258a:	85ca                	mv	a1,s2
    8000258c:	7528                	ld	a0,104(a0)
    8000258e:	fffff097          	auipc	ra,0xfffff
    80002592:	1e0080e7          	jalr	480(ra) # 8000176e <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002596:	70a2                	ld	ra,40(sp)
    80002598:	7402                	ld	s0,32(sp)
    8000259a:	64e2                	ld	s1,24(sp)
    8000259c:	6942                	ld	s2,16(sp)
    8000259e:	69a2                	ld	s3,8(sp)
    800025a0:	6a02                	ld	s4,0(sp)
    800025a2:	6145                	add	sp,sp,48
    800025a4:	8082                	ret
    memmove(dst, (char*)src, len);
    800025a6:	000a061b          	sext.w	a2,s4
    800025aa:	85ce                	mv	a1,s3
    800025ac:	854a                	mv	a0,s2
    800025ae:	ffffe097          	auipc	ra,0xffffe
    800025b2:	7e2080e7          	jalr	2018(ra) # 80000d90 <memmove>
    return 0;
    800025b6:	8526                	mv	a0,s1
    800025b8:	bff9                	j	80002596 <either_copyin+0x32>

00000000800025ba <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025ba:	715d                	add	sp,sp,-80
    800025bc:	e486                	sd	ra,72(sp)
    800025be:	e0a2                	sd	s0,64(sp)
    800025c0:	fc26                	sd	s1,56(sp)
    800025c2:	f84a                	sd	s2,48(sp)
    800025c4:	f44e                	sd	s3,40(sp)
    800025c6:	f052                	sd	s4,32(sp)
    800025c8:	ec56                	sd	s5,24(sp)
    800025ca:	e85a                	sd	s6,16(sp)
    800025cc:	e45e                	sd	s7,8(sp)
    800025ce:	0880                	add	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025d0:	00006517          	auipc	a0,0x6
    800025d4:	ae850513          	add	a0,a0,-1304 # 800080b8 <digits+0x88>
    800025d8:	ffffe097          	auipc	ra,0xffffe
    800025dc:	fd2080e7          	jalr	-46(ra) # 800005aa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025e0:	00011497          	auipc	s1,0x11
    800025e4:	4a048493          	add	s1,s1,1184 # 80013a80 <proc+0x170>
    800025e8:	00017917          	auipc	s2,0x17
    800025ec:	49890913          	add	s2,s2,1176 # 80019a80 <bcache+0x158>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025f0:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025f2:	00006997          	auipc	s3,0x6
    800025f6:	c7e98993          	add	s3,s3,-898 # 80008270 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    800025fa:	00006a97          	auipc	s5,0x6
    800025fe:	c7ea8a93          	add	s5,s5,-898 # 80008278 <digits+0x248>
    printf("\n");
    80002602:	00006a17          	auipc	s4,0x6
    80002606:	ab6a0a13          	add	s4,s4,-1354 # 800080b8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000260a:	00006b97          	auipc	s7,0x6
    8000260e:	caeb8b93          	add	s7,s7,-850 # 800082b8 <states.0>
    80002612:	a00d                	j	80002634 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002614:	ec06a583          	lw	a1,-320(a3)
    80002618:	8556                	mv	a0,s5
    8000261a:	ffffe097          	auipc	ra,0xffffe
    8000261e:	f90080e7          	jalr	-112(ra) # 800005aa <printf>
    printf("\n");
    80002622:	8552                	mv	a0,s4
    80002624:	ffffe097          	auipc	ra,0xffffe
    80002628:	f86080e7          	jalr	-122(ra) # 800005aa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000262c:	18048493          	add	s1,s1,384
    80002630:	03248263          	beq	s1,s2,80002654 <procdump+0x9a>
    if(p->state == UNUSED)
    80002634:	86a6                	mv	a3,s1
    80002636:	ea84a783          	lw	a5,-344(s1)
    8000263a:	dbed                	beqz	a5,8000262c <procdump+0x72>
      state = "???";
    8000263c:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000263e:	fcfb6be3          	bltu	s6,a5,80002614 <procdump+0x5a>
    80002642:	02079713          	sll	a4,a5,0x20
    80002646:	01d75793          	srl	a5,a4,0x1d
    8000264a:	97de                	add	a5,a5,s7
    8000264c:	6390                	ld	a2,0(a5)
    8000264e:	f279                	bnez	a2,80002614 <procdump+0x5a>
      state = "???";
    80002650:	864e                	mv	a2,s3
    80002652:	b7c9                	j	80002614 <procdump+0x5a>
  }
}
    80002654:	60a6                	ld	ra,72(sp)
    80002656:	6406                	ld	s0,64(sp)
    80002658:	74e2                	ld	s1,56(sp)
    8000265a:	7942                	ld	s2,48(sp)
    8000265c:	79a2                	ld	s3,40(sp)
    8000265e:	7a02                	ld	s4,32(sp)
    80002660:	6ae2                	ld	s5,24(sp)
    80002662:	6b42                	ld	s6,16(sp)
    80002664:	6ba2                	ld	s7,8(sp)
    80002666:	6161                	add	sp,sp,80
    80002668:	8082                	ret

000000008000266a <swtch>:
    8000266a:	00153023          	sd	ra,0(a0)
    8000266e:	00253423          	sd	sp,8(a0)
    80002672:	e900                	sd	s0,16(a0)
    80002674:	ed04                	sd	s1,24(a0)
    80002676:	03253023          	sd	s2,32(a0)
    8000267a:	03353423          	sd	s3,40(a0)
    8000267e:	03453823          	sd	s4,48(a0)
    80002682:	03553c23          	sd	s5,56(a0)
    80002686:	05653023          	sd	s6,64(a0)
    8000268a:	05753423          	sd	s7,72(a0)
    8000268e:	05853823          	sd	s8,80(a0)
    80002692:	05953c23          	sd	s9,88(a0)
    80002696:	07a53023          	sd	s10,96(a0)
    8000269a:	07b53423          	sd	s11,104(a0)
    8000269e:	0005b083          	ld	ra,0(a1)
    800026a2:	0085b103          	ld	sp,8(a1)
    800026a6:	6980                	ld	s0,16(a1)
    800026a8:	6d84                	ld	s1,24(a1)
    800026aa:	0205b903          	ld	s2,32(a1)
    800026ae:	0285b983          	ld	s3,40(a1)
    800026b2:	0305ba03          	ld	s4,48(a1)
    800026b6:	0385ba83          	ld	s5,56(a1)
    800026ba:	0405bb03          	ld	s6,64(a1)
    800026be:	0485bb83          	ld	s7,72(a1)
    800026c2:	0505bc03          	ld	s8,80(a1)
    800026c6:	0585bc83          	ld	s9,88(a1)
    800026ca:	0605bd03          	ld	s10,96(a1)
    800026ce:	0685bd83          	ld	s11,104(a1)
    800026d2:	8082                	ret

00000000800026d4 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800026d4:	1141                	add	sp,sp,-16
    800026d6:	e406                	sd	ra,8(sp)
    800026d8:	e022                	sd	s0,0(sp)
    800026da:	0800                	add	s0,sp,16
  initlock(&tickslock, "time");
    800026dc:	00006597          	auipc	a1,0x6
    800026e0:	c0c58593          	add	a1,a1,-1012 # 800082e8 <states.0+0x30>
    800026e4:	00017517          	auipc	a0,0x17
    800026e8:	22c50513          	add	a0,a0,556 # 80019910 <tickslock>
    800026ec:	ffffe097          	auipc	ra,0xffffe
    800026f0:	4bc080e7          	jalr	1212(ra) # 80000ba8 <initlock>
}
    800026f4:	60a2                	ld	ra,8(sp)
    800026f6:	6402                	ld	s0,0(sp)
    800026f8:	0141                	add	sp,sp,16
    800026fa:	8082                	ret

00000000800026fc <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026fc:	1141                	add	sp,sp,-16
    800026fe:	e422                	sd	s0,8(sp)
    80002700:	0800                	add	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002702:	00003797          	auipc	a5,0x3
    80002706:	7ce78793          	add	a5,a5,1998 # 80005ed0 <kernelvec>
    8000270a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000270e:	6422                	ld	s0,8(sp)
    80002710:	0141                	add	sp,sp,16
    80002712:	8082                	ret

0000000080002714 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002714:	1141                	add	sp,sp,-16
    80002716:	e406                	sd	ra,8(sp)
    80002718:	e022                	sd	s0,0(sp)
    8000271a:	0800                	add	s0,sp,16
  struct proc *p = myproc();
    8000271c:	fffff097          	auipc	ra,0xfffff
    80002720:	32e080e7          	jalr	814(ra) # 80001a4a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002724:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002728:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000272a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000272e:	00005697          	auipc	a3,0x5
    80002732:	8d268693          	add	a3,a3,-1838 # 80007000 <_trampoline>
    80002736:	00005717          	auipc	a4,0x5
    8000273a:	8ca70713          	add	a4,a4,-1846 # 80007000 <_trampoline>
    8000273e:	8f15                	sub	a4,a4,a3
    80002740:	040007b7          	lui	a5,0x4000
    80002744:	17fd                	add	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002746:	07b2                	sll	a5,a5,0xc
    80002748:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000274a:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000274e:	7938                	ld	a4,112(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002750:	18002673          	csrr	a2,satp
    80002754:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002756:	7930                	ld	a2,112(a0)
    80002758:	6d38                	ld	a4,88(a0)
    8000275a:	6585                	lui	a1,0x1
    8000275c:	972e                	add	a4,a4,a1
    8000275e:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002760:	7938                	ld	a4,112(a0)
    80002762:	00000617          	auipc	a2,0x0
    80002766:	13860613          	add	a2,a2,312 # 8000289a <usertrap>
    8000276a:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000276c:	7938                	ld	a4,112(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000276e:	8612                	mv	a2,tp
    80002770:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002772:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002776:	eff77713          	and	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000277a:	02076713          	or	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000277e:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002782:	7938                	ld	a4,112(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002784:	6f18                	ld	a4,24(a4)
    80002786:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000278a:	7528                	ld	a0,104(a0)
    8000278c:	8131                	srl	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000278e:	00005717          	auipc	a4,0x5
    80002792:	90e70713          	add	a4,a4,-1778 # 8000709c <userret>
    80002796:	8f15                	sub	a4,a4,a3
    80002798:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000279a:	577d                	li	a4,-1
    8000279c:	177e                	sll	a4,a4,0x3f
    8000279e:	8d59                	or	a0,a0,a4
    800027a0:	9782                	jalr	a5
}
    800027a2:	60a2                	ld	ra,8(sp)
    800027a4:	6402                	ld	s0,0(sp)
    800027a6:	0141                	add	sp,sp,16
    800027a8:	8082                	ret

00000000800027aa <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800027aa:	1101                	add	sp,sp,-32
    800027ac:	ec06                	sd	ra,24(sp)
    800027ae:	e822                	sd	s0,16(sp)
    800027b0:	e426                	sd	s1,8(sp)
    800027b2:	1000                	add	s0,sp,32
  acquire(&tickslock);
    800027b4:	00017497          	auipc	s1,0x17
    800027b8:	15c48493          	add	s1,s1,348 # 80019910 <tickslock>
    800027bc:	8526                	mv	a0,s1
    800027be:	ffffe097          	auipc	ra,0xffffe
    800027c2:	47a080e7          	jalr	1146(ra) # 80000c38 <acquire>
  ticks++;
    800027c6:	00009517          	auipc	a0,0x9
    800027ca:	aaa50513          	add	a0,a0,-1366 # 8000b270 <ticks>
    800027ce:	411c                	lw	a5,0(a0)
    800027d0:	2785                	addw	a5,a5,1
    800027d2:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800027d4:	00000097          	auipc	ra,0x0
    800027d8:	996080e7          	jalr	-1642(ra) # 8000216a <wakeup>
  release(&tickslock);
    800027dc:	8526                	mv	a0,s1
    800027de:	ffffe097          	auipc	ra,0xffffe
    800027e2:	50e080e7          	jalr	1294(ra) # 80000cec <release>
}
    800027e6:	60e2                	ld	ra,24(sp)
    800027e8:	6442                	ld	s0,16(sp)
    800027ea:	64a2                	ld	s1,8(sp)
    800027ec:	6105                	add	sp,sp,32
    800027ee:	8082                	ret

00000000800027f0 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027f0:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027f4:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    800027f6:	0a07d163          	bgez	a5,80002898 <devintr+0xa8>
{
    800027fa:	1101                	add	sp,sp,-32
    800027fc:	ec06                	sd	ra,24(sp)
    800027fe:	e822                	sd	s0,16(sp)
    80002800:	1000                	add	s0,sp,32
     (scause & 0xff) == 9){
    80002802:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002806:	46a5                	li	a3,9
    80002808:	00d70c63          	beq	a4,a3,80002820 <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    8000280c:	577d                	li	a4,-1
    8000280e:	177e                	sll	a4,a4,0x3f
    80002810:	0705                	add	a4,a4,1
    return 0;
    80002812:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002814:	06e78163          	beq	a5,a4,80002876 <devintr+0x86>
  }
}
    80002818:	60e2                	ld	ra,24(sp)
    8000281a:	6442                	ld	s0,16(sp)
    8000281c:	6105                	add	sp,sp,32
    8000281e:	8082                	ret
    80002820:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002822:	00003097          	auipc	ra,0x3
    80002826:	7ba080e7          	jalr	1978(ra) # 80005fdc <plic_claim>
    8000282a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000282c:	47a9                	li	a5,10
    8000282e:	00f50963          	beq	a0,a5,80002840 <devintr+0x50>
    } else if(irq == VIRTIO0_IRQ){
    80002832:	4785                	li	a5,1
    80002834:	00f50b63          	beq	a0,a5,8000284a <devintr+0x5a>
    return 1;
    80002838:	4505                	li	a0,1
    } else if(irq){
    8000283a:	ec89                	bnez	s1,80002854 <devintr+0x64>
    8000283c:	64a2                	ld	s1,8(sp)
    8000283e:	bfe9                	j	80002818 <devintr+0x28>
      uartintr();
    80002840:	ffffe097          	auipc	ra,0xffffe
    80002844:	1ba080e7          	jalr	442(ra) # 800009fa <uartintr>
    if(irq) {
    80002848:	a839                	j	80002866 <devintr+0x76>
      virtio_disk_intr();
    8000284a:	00004097          	auipc	ra,0x4
    8000284e:	cbc080e7          	jalr	-836(ra) # 80006506 <virtio_disk_intr>
    if(irq) {
    80002852:	a811                	j	80002866 <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    80002854:	85a6                	mv	a1,s1
    80002856:	00006517          	auipc	a0,0x6
    8000285a:	a9a50513          	add	a0,a0,-1382 # 800082f0 <states.0+0x38>
    8000285e:	ffffe097          	auipc	ra,0xffffe
    80002862:	d4c080e7          	jalr	-692(ra) # 800005aa <printf>
      plic_complete(irq);
    80002866:	8526                	mv	a0,s1
    80002868:	00003097          	auipc	ra,0x3
    8000286c:	798080e7          	jalr	1944(ra) # 80006000 <plic_complete>
    return 1;
    80002870:	4505                	li	a0,1
    80002872:	64a2                	ld	s1,8(sp)
    80002874:	b755                	j	80002818 <devintr+0x28>
    if(cpuid() == 0){
    80002876:	fffff097          	auipc	ra,0xfffff
    8000287a:	1a8080e7          	jalr	424(ra) # 80001a1e <cpuid>
    8000287e:	c901                	beqz	a0,8000288e <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002880:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002884:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002886:	14479073          	csrw	sip,a5
    return 2;
    8000288a:	4509                	li	a0,2
    8000288c:	b771                	j	80002818 <devintr+0x28>
      clockintr();
    8000288e:	00000097          	auipc	ra,0x0
    80002892:	f1c080e7          	jalr	-228(ra) # 800027aa <clockintr>
    80002896:	b7ed                	j	80002880 <devintr+0x90>
}
    80002898:	8082                	ret

000000008000289a <usertrap>:
{
    8000289a:	1101                	add	sp,sp,-32
    8000289c:	ec06                	sd	ra,24(sp)
    8000289e:	e822                	sd	s0,16(sp)
    800028a0:	1000                	add	s0,sp,32
  struct proc *p = myproc();
    800028a2:	fffff097          	auipc	ra,0xfffff
    800028a6:	1a8080e7          	jalr	424(ra) # 80001a4a <myproc>
  if (!p) return; // Safety check
    800028aa:	c95d                	beqz	a0,80002960 <usertrap+0xc6>
    800028ac:	e426                	sd	s1,8(sp)
    800028ae:	e04a                	sd	s2,0(sp)
    800028b0:	84aa                	mv	s1,a0
  p->trapCount++;  // Increment traps counter
    800028b2:	417c                	lw	a5,68(a0)
    800028b4:	2785                	addw	a5,a5,1
    800028b6:	c17c                	sw	a5,68(a0)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028b8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800028bc:	1007f793          	and	a5,a5,256
    800028c0:	ef8d                	bnez	a5,800028fa <usertrap+0x60>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028c2:	00003797          	auipc	a5,0x3
    800028c6:	60e78793          	add	a5,a5,1550 # 80005ed0 <kernelvec>
    800028ca:	10579073          	csrw	stvec,a5
  p->trapframe->epc = r_sepc();
    800028ce:	793c                	ld	a5,112(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028d0:	14102773          	csrr	a4,sepc
    800028d4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028d6:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800028da:	47a1                	li	a5,8
    800028dc:	02f70763          	beq	a4,a5,8000290a <usertrap+0x70>
  } else if((which_dev = devintr()) != 0){
    800028e0:	00000097          	auipc	ra,0x0
    800028e4:	f10080e7          	jalr	-240(ra) # 800027f0 <devintr>
    800028e8:	892a                	mv	s2,a0
    800028ea:	c549                	beqz	a0,80002974 <usertrap+0xda>
  if(killed(p))
    800028ec:	8526                	mv	a0,s1
    800028ee:	00000097          	auipc	ra,0x0
    800028f2:	ac0080e7          	jalr	-1344(ra) # 800023ae <killed>
    800028f6:	cd21                	beqz	a0,8000294e <usertrap+0xb4>
    800028f8:	a0b1                	j	80002944 <usertrap+0xaa>
    panic("usertrap: not from user mode");
    800028fa:	00006517          	auipc	a0,0x6
    800028fe:	a1650513          	add	a0,a0,-1514 # 80008310 <states.0+0x58>
    80002902:	ffffe097          	auipc	ra,0xffffe
    80002906:	c5e080e7          	jalr	-930(ra) # 80000560 <panic>
    p->systemcallCount++;  // Increment systemcallCount
    8000290a:	5d1c                	lw	a5,56(a0)
    8000290c:	2785                	addw	a5,a5,1
    8000290e:	dd1c                	sw	a5,56(a0)
    if(killed(p))
    80002910:	00000097          	auipc	ra,0x0
    80002914:	a9e080e7          	jalr	-1378(ra) # 800023ae <killed>
    80002918:	e921                	bnez	a0,80002968 <usertrap+0xce>
    p->trapframe->epc += 4;
    8000291a:	78b8                	ld	a4,112(s1)
    8000291c:	6f1c                	ld	a5,24(a4)
    8000291e:	0791                	add	a5,a5,4
    80002920:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002922:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002926:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000292a:	10079073          	csrw	sstatus,a5
    syscall();
    8000292e:	00000097          	auipc	ra,0x0
    80002932:	2da080e7          	jalr	730(ra) # 80002c08 <syscall>
  if(killed(p))
    80002936:	8526                	mv	a0,s1
    80002938:	00000097          	auipc	ra,0x0
    8000293c:	a76080e7          	jalr	-1418(ra) # 800023ae <killed>
    80002940:	c911                	beqz	a0,80002954 <usertrap+0xba>
    80002942:	4901                	li	s2,0
    exit(-1);
    80002944:	557d                	li	a0,-1
    80002946:	00000097          	auipc	ra,0x0
    8000294a:	8f4080e7          	jalr	-1804(ra) # 8000223a <exit>
  if(which_dev == 2) {
    8000294e:	4789                	li	a5,2
    80002950:	04f90f63          	beq	s2,a5,800029ae <usertrap+0x114>
  usertrapret();
    80002954:	00000097          	auipc	ra,0x0
    80002958:	dc0080e7          	jalr	-576(ra) # 80002714 <usertrapret>
    8000295c:	64a2                	ld	s1,8(sp)
    8000295e:	6902                	ld	s2,0(sp)
}
    80002960:	60e2                	ld	ra,24(sp)
    80002962:	6442                	ld	s0,16(sp)
    80002964:	6105                	add	sp,sp,32
    80002966:	8082                	ret
      exit(-1);
    80002968:	557d                	li	a0,-1
    8000296a:	00000097          	auipc	ra,0x0
    8000296e:	8d0080e7          	jalr	-1840(ra) # 8000223a <exit>
    80002972:	b765                	j	8000291a <usertrap+0x80>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002974:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002978:	5890                	lw	a2,48(s1)
    8000297a:	00006517          	auipc	a0,0x6
    8000297e:	9b650513          	add	a0,a0,-1610 # 80008330 <states.0+0x78>
    80002982:	ffffe097          	auipc	ra,0xffffe
    80002986:	c28080e7          	jalr	-984(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000298a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000298e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002992:	00006517          	auipc	a0,0x6
    80002996:	9ce50513          	add	a0,a0,-1586 # 80008360 <states.0+0xa8>
    8000299a:	ffffe097          	auipc	ra,0xffffe
    8000299e:	c10080e7          	jalr	-1008(ra) # 800005aa <printf>
    setkilled(p);
    800029a2:	8526                	mv	a0,s1
    800029a4:	00000097          	auipc	ra,0x0
    800029a8:	9de080e7          	jalr	-1570(ra) # 80002382 <setkilled>
    800029ac:	b769                	j	80002936 <usertrap+0x9c>
    p->interruptCount++;  // Make sure interrupts are counted when a process context exists.
    800029ae:	5cdc                	lw	a5,60(s1)
    800029b0:	2785                	addw	a5,a5,1
    800029b2:	dcdc                	sw	a5,60(s1)
    yield();
    800029b4:	fffff097          	auipc	ra,0xfffff
    800029b8:	70a080e7          	jalr	1802(ra) # 800020be <yield>
    800029bc:	bf61                	j	80002954 <usertrap+0xba>

00000000800029be <kerneltrap>:
{
    800029be:	7179                	add	sp,sp,-48
    800029c0:	f406                	sd	ra,40(sp)
    800029c2:	f022                	sd	s0,32(sp)
    800029c4:	ec26                	sd	s1,24(sp)
    800029c6:	e84a                	sd	s2,16(sp)
    800029c8:	e44e                	sd	s3,8(sp)
    800029ca:	1800                	add	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029cc:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029d0:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029d4:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800029d8:	1004f793          	and	a5,s1,256
    800029dc:	cb85                	beqz	a5,80002a0c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029de:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029e2:	8b89                	and	a5,a5,2
  if(intr_get() != 0)
    800029e4:	ef85                	bnez	a5,80002a1c <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800029e6:	00000097          	auipc	ra,0x0
    800029ea:	e0a080e7          	jalr	-502(ra) # 800027f0 <devintr>
    800029ee:	cd1d                	beqz	a0,80002a2c <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029f0:	4789                	li	a5,2
    800029f2:	06f50a63          	beq	a0,a5,80002a66 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029f6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029fa:	10049073          	csrw	sstatus,s1
}
    800029fe:	70a2                	ld	ra,40(sp)
    80002a00:	7402                	ld	s0,32(sp)
    80002a02:	64e2                	ld	s1,24(sp)
    80002a04:	6942                	ld	s2,16(sp)
    80002a06:	69a2                	ld	s3,8(sp)
    80002a08:	6145                	add	sp,sp,48
    80002a0a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a0c:	00006517          	auipc	a0,0x6
    80002a10:	97450513          	add	a0,a0,-1676 # 80008380 <states.0+0xc8>
    80002a14:	ffffe097          	auipc	ra,0xffffe
    80002a18:	b4c080e7          	jalr	-1204(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    80002a1c:	00006517          	auipc	a0,0x6
    80002a20:	98c50513          	add	a0,a0,-1652 # 800083a8 <states.0+0xf0>
    80002a24:	ffffe097          	auipc	ra,0xffffe
    80002a28:	b3c080e7          	jalr	-1220(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    80002a2c:	85ce                	mv	a1,s3
    80002a2e:	00006517          	auipc	a0,0x6
    80002a32:	99a50513          	add	a0,a0,-1638 # 800083c8 <states.0+0x110>
    80002a36:	ffffe097          	auipc	ra,0xffffe
    80002a3a:	b74080e7          	jalr	-1164(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a3e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a42:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a46:	00006517          	auipc	a0,0x6
    80002a4a:	99250513          	add	a0,a0,-1646 # 800083d8 <states.0+0x120>
    80002a4e:	ffffe097          	auipc	ra,0xffffe
    80002a52:	b5c080e7          	jalr	-1188(ra) # 800005aa <printf>
    panic("kerneltrap");
    80002a56:	00006517          	auipc	a0,0x6
    80002a5a:	99a50513          	add	a0,a0,-1638 # 800083f0 <states.0+0x138>
    80002a5e:	ffffe097          	auipc	ra,0xffffe
    80002a62:	b02080e7          	jalr	-1278(ra) # 80000560 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a66:	fffff097          	auipc	ra,0xfffff
    80002a6a:	fe4080e7          	jalr	-28(ra) # 80001a4a <myproc>
    80002a6e:	d541                	beqz	a0,800029f6 <kerneltrap+0x38>
    80002a70:	fffff097          	auipc	ra,0xfffff
    80002a74:	fda080e7          	jalr	-38(ra) # 80001a4a <myproc>
    80002a78:	4d18                	lw	a4,24(a0)
    80002a7a:	4791                	li	a5,4
    80002a7c:	f6f71de3          	bne	a4,a5,800029f6 <kerneltrap+0x38>
    yield();
    80002a80:	fffff097          	auipc	ra,0xfffff
    80002a84:	63e080e7          	jalr	1598(ra) # 800020be <yield>
    80002a88:	b7bd                	j	800029f6 <kerneltrap+0x38>

0000000080002a8a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a8a:	1101                	add	sp,sp,-32
    80002a8c:	ec06                	sd	ra,24(sp)
    80002a8e:	e822                	sd	s0,16(sp)
    80002a90:	e426                	sd	s1,8(sp)
    80002a92:	1000                	add	s0,sp,32
    80002a94:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a96:	fffff097          	auipc	ra,0xfffff
    80002a9a:	fb4080e7          	jalr	-76(ra) # 80001a4a <myproc>
  switch (n) {
    80002a9e:	4795                	li	a5,5
    80002aa0:	0497e163          	bltu	a5,s1,80002ae2 <argraw+0x58>
    80002aa4:	048a                	sll	s1,s1,0x2
    80002aa6:	00006717          	auipc	a4,0x6
    80002aaa:	98270713          	add	a4,a4,-1662 # 80008428 <states.0+0x170>
    80002aae:	94ba                	add	s1,s1,a4
    80002ab0:	409c                	lw	a5,0(s1)
    80002ab2:	97ba                	add	a5,a5,a4
    80002ab4:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002ab6:	793c                	ld	a5,112(a0)
    80002ab8:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002aba:	60e2                	ld	ra,24(sp)
    80002abc:	6442                	ld	s0,16(sp)
    80002abe:	64a2                	ld	s1,8(sp)
    80002ac0:	6105                	add	sp,sp,32
    80002ac2:	8082                	ret
    return p->trapframe->a1;
    80002ac4:	793c                	ld	a5,112(a0)
    80002ac6:	7fa8                	ld	a0,120(a5)
    80002ac8:	bfcd                	j	80002aba <argraw+0x30>
    return p->trapframe->a2;
    80002aca:	793c                	ld	a5,112(a0)
    80002acc:	63c8                	ld	a0,128(a5)
    80002ace:	b7f5                	j	80002aba <argraw+0x30>
    return p->trapframe->a3;
    80002ad0:	793c                	ld	a5,112(a0)
    80002ad2:	67c8                	ld	a0,136(a5)
    80002ad4:	b7dd                	j	80002aba <argraw+0x30>
    return p->trapframe->a4;
    80002ad6:	793c                	ld	a5,112(a0)
    80002ad8:	6bc8                	ld	a0,144(a5)
    80002ada:	b7c5                	j	80002aba <argraw+0x30>
    return p->trapframe->a5;
    80002adc:	793c                	ld	a5,112(a0)
    80002ade:	6fc8                	ld	a0,152(a5)
    80002ae0:	bfe9                	j	80002aba <argraw+0x30>
  panic("argraw");
    80002ae2:	00006517          	auipc	a0,0x6
    80002ae6:	91e50513          	add	a0,a0,-1762 # 80008400 <states.0+0x148>
    80002aea:	ffffe097          	auipc	ra,0xffffe
    80002aee:	a76080e7          	jalr	-1418(ra) # 80000560 <panic>

0000000080002af2 <fetchaddr>:
{
    80002af2:	1101                	add	sp,sp,-32
    80002af4:	ec06                	sd	ra,24(sp)
    80002af6:	e822                	sd	s0,16(sp)
    80002af8:	e426                	sd	s1,8(sp)
    80002afa:	e04a                	sd	s2,0(sp)
    80002afc:	1000                	add	s0,sp,32
    80002afe:	84aa                	mv	s1,a0
    80002b00:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b02:	fffff097          	auipc	ra,0xfffff
    80002b06:	f48080e7          	jalr	-184(ra) # 80001a4a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002b0a:	713c                	ld	a5,96(a0)
    80002b0c:	02f4f863          	bgeu	s1,a5,80002b3c <fetchaddr+0x4a>
    80002b10:	00848713          	add	a4,s1,8
    80002b14:	02e7e663          	bltu	a5,a4,80002b40 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b18:	46a1                	li	a3,8
    80002b1a:	8626                	mv	a2,s1
    80002b1c:	85ca                	mv	a1,s2
    80002b1e:	7528                	ld	a0,104(a0)
    80002b20:	fffff097          	auipc	ra,0xfffff
    80002b24:	c4e080e7          	jalr	-946(ra) # 8000176e <copyin>
    80002b28:	00a03533          	snez	a0,a0
    80002b2c:	40a00533          	neg	a0,a0
}
    80002b30:	60e2                	ld	ra,24(sp)
    80002b32:	6442                	ld	s0,16(sp)
    80002b34:	64a2                	ld	s1,8(sp)
    80002b36:	6902                	ld	s2,0(sp)
    80002b38:	6105                	add	sp,sp,32
    80002b3a:	8082                	ret
    return -1;
    80002b3c:	557d                	li	a0,-1
    80002b3e:	bfcd                	j	80002b30 <fetchaddr+0x3e>
    80002b40:	557d                	li	a0,-1
    80002b42:	b7fd                	j	80002b30 <fetchaddr+0x3e>

0000000080002b44 <fetchstr>:
{
    80002b44:	7179                	add	sp,sp,-48
    80002b46:	f406                	sd	ra,40(sp)
    80002b48:	f022                	sd	s0,32(sp)
    80002b4a:	ec26                	sd	s1,24(sp)
    80002b4c:	e84a                	sd	s2,16(sp)
    80002b4e:	e44e                	sd	s3,8(sp)
    80002b50:	1800                	add	s0,sp,48
    80002b52:	892a                	mv	s2,a0
    80002b54:	84ae                	mv	s1,a1
    80002b56:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b58:	fffff097          	auipc	ra,0xfffff
    80002b5c:	ef2080e7          	jalr	-270(ra) # 80001a4a <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002b60:	86ce                	mv	a3,s3
    80002b62:	864a                	mv	a2,s2
    80002b64:	85a6                	mv	a1,s1
    80002b66:	7528                	ld	a0,104(a0)
    80002b68:	fffff097          	auipc	ra,0xfffff
    80002b6c:	c94080e7          	jalr	-876(ra) # 800017fc <copyinstr>
    80002b70:	00054e63          	bltz	a0,80002b8c <fetchstr+0x48>
  return strlen(buf);
    80002b74:	8526                	mv	a0,s1
    80002b76:	ffffe097          	auipc	ra,0xffffe
    80002b7a:	332080e7          	jalr	818(ra) # 80000ea8 <strlen>
}
    80002b7e:	70a2                	ld	ra,40(sp)
    80002b80:	7402                	ld	s0,32(sp)
    80002b82:	64e2                	ld	s1,24(sp)
    80002b84:	6942                	ld	s2,16(sp)
    80002b86:	69a2                	ld	s3,8(sp)
    80002b88:	6145                	add	sp,sp,48
    80002b8a:	8082                	ret
    return -1;
    80002b8c:	557d                	li	a0,-1
    80002b8e:	bfc5                	j	80002b7e <fetchstr+0x3a>

0000000080002b90 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b90:	1101                	add	sp,sp,-32
    80002b92:	ec06                	sd	ra,24(sp)
    80002b94:	e822                	sd	s0,16(sp)
    80002b96:	e426                	sd	s1,8(sp)
    80002b98:	1000                	add	s0,sp,32
    80002b9a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b9c:	00000097          	auipc	ra,0x0
    80002ba0:	eee080e7          	jalr	-274(ra) # 80002a8a <argraw>
    80002ba4:	c088                	sw	a0,0(s1)
}
    80002ba6:	60e2                	ld	ra,24(sp)
    80002ba8:	6442                	ld	s0,16(sp)
    80002baa:	64a2                	ld	s1,8(sp)
    80002bac:	6105                	add	sp,sp,32
    80002bae:	8082                	ret

0000000080002bb0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002bb0:	1101                	add	sp,sp,-32
    80002bb2:	ec06                	sd	ra,24(sp)
    80002bb4:	e822                	sd	s0,16(sp)
    80002bb6:	e426                	sd	s1,8(sp)
    80002bb8:	1000                	add	s0,sp,32
    80002bba:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bbc:	00000097          	auipc	ra,0x0
    80002bc0:	ece080e7          	jalr	-306(ra) # 80002a8a <argraw>
    80002bc4:	e088                	sd	a0,0(s1)
}
    80002bc6:	60e2                	ld	ra,24(sp)
    80002bc8:	6442                	ld	s0,16(sp)
    80002bca:	64a2                	ld	s1,8(sp)
    80002bcc:	6105                	add	sp,sp,32
    80002bce:	8082                	ret

0000000080002bd0 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002bd0:	7179                	add	sp,sp,-48
    80002bd2:	f406                	sd	ra,40(sp)
    80002bd4:	f022                	sd	s0,32(sp)
    80002bd6:	ec26                	sd	s1,24(sp)
    80002bd8:	e84a                	sd	s2,16(sp)
    80002bda:	1800                	add	s0,sp,48
    80002bdc:	84ae                	mv	s1,a1
    80002bde:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002be0:	fd840593          	add	a1,s0,-40
    80002be4:	00000097          	auipc	ra,0x0
    80002be8:	fcc080e7          	jalr	-52(ra) # 80002bb0 <argaddr>
  return fetchstr(addr, buf, max);
    80002bec:	864a                	mv	a2,s2
    80002bee:	85a6                	mv	a1,s1
    80002bf0:	fd843503          	ld	a0,-40(s0)
    80002bf4:	00000097          	auipc	ra,0x0
    80002bf8:	f50080e7          	jalr	-176(ra) # 80002b44 <fetchstr>
}
    80002bfc:	70a2                	ld	ra,40(sp)
    80002bfe:	7402                	ld	s0,32(sp)
    80002c00:	64e2                	ld	s1,24(sp)
    80002c02:	6942                	ld	s2,16(sp)
    80002c04:	6145                	add	sp,sp,48
    80002c06:	8082                	ret

0000000080002c08 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002c08:	1101                	add	sp,sp,-32
    80002c0a:	ec06                	sd	ra,24(sp)
    80002c0c:	e822                	sd	s0,16(sp)
    80002c0e:	e426                	sd	s1,8(sp)
    80002c10:	e04a                	sd	s2,0(sp)
    80002c12:	1000                	add	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c14:	fffff097          	auipc	ra,0xfffff
    80002c18:	e36080e7          	jalr	-458(ra) # 80001a4a <myproc>
    80002c1c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002c1e:	07053903          	ld	s2,112(a0)
    80002c22:	0a893783          	ld	a5,168(s2)
    80002c26:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c2a:	37fd                	addw	a5,a5,-1
    80002c2c:	475d                	li	a4,23
    80002c2e:	00f76f63          	bltu	a4,a5,80002c4c <syscall+0x44>
    80002c32:	00369713          	sll	a4,a3,0x3
    80002c36:	00006797          	auipc	a5,0x6
    80002c3a:	80a78793          	add	a5,a5,-2038 # 80008440 <syscalls>
    80002c3e:	97ba                	add	a5,a5,a4
    80002c40:	639c                	ld	a5,0(a5)
    80002c42:	c789                	beqz	a5,80002c4c <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002c44:	9782                	jalr	a5
    80002c46:	06a93823          	sd	a0,112(s2)
    80002c4a:	a839                	j	80002c68 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c4c:	17048613          	add	a2,s1,368
    80002c50:	588c                	lw	a1,48(s1)
    80002c52:	00005517          	auipc	a0,0x5
    80002c56:	7b650513          	add	a0,a0,1974 # 80008408 <states.0+0x150>
    80002c5a:	ffffe097          	auipc	ra,0xffffe
    80002c5e:	950080e7          	jalr	-1712(ra) # 800005aa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c62:	78bc                	ld	a5,112(s1)
    80002c64:	577d                	li	a4,-1
    80002c66:	fbb8                	sd	a4,112(a5)
  }
}
    80002c68:	60e2                	ld	ra,24(sp)
    80002c6a:	6442                	ld	s0,16(sp)
    80002c6c:	64a2                	ld	s1,8(sp)
    80002c6e:	6902                	ld	s2,0(sp)
    80002c70:	6105                	add	sp,sp,32
    80002c72:	8082                	ret

0000000080002c74 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c74:	1101                	add	sp,sp,-32
    80002c76:	ec06                	sd	ra,24(sp)
    80002c78:	e822                	sd	s0,16(sp)
    80002c7a:	1000                	add	s0,sp,32
  int n;
  argint(0, &n);
    80002c7c:	fec40593          	add	a1,s0,-20
    80002c80:	4501                	li	a0,0
    80002c82:	00000097          	auipc	ra,0x0
    80002c86:	f0e080e7          	jalr	-242(ra) # 80002b90 <argint>
  exit(n);
    80002c8a:	fec42503          	lw	a0,-20(s0)
    80002c8e:	fffff097          	auipc	ra,0xfffff
    80002c92:	5ac080e7          	jalr	1452(ra) # 8000223a <exit>
  return 0;  // not reached
}
    80002c96:	4501                	li	a0,0
    80002c98:	60e2                	ld	ra,24(sp)
    80002c9a:	6442                	ld	s0,16(sp)
    80002c9c:	6105                	add	sp,sp,32
    80002c9e:	8082                	ret

0000000080002ca0 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ca0:	1141                	add	sp,sp,-16
    80002ca2:	e406                	sd	ra,8(sp)
    80002ca4:	e022                	sd	s0,0(sp)
    80002ca6:	0800                	add	s0,sp,16
  return myproc()->pid;
    80002ca8:	fffff097          	auipc	ra,0xfffff
    80002cac:	da2080e7          	jalr	-606(ra) # 80001a4a <myproc>
}
    80002cb0:	5908                	lw	a0,48(a0)
    80002cb2:	60a2                	ld	ra,8(sp)
    80002cb4:	6402                	ld	s0,0(sp)
    80002cb6:	0141                	add	sp,sp,16
    80002cb8:	8082                	ret

0000000080002cba <sys_fork>:

uint64
sys_fork(void)
{
    80002cba:	1141                	add	sp,sp,-16
    80002cbc:	e406                	sd	ra,8(sp)
    80002cbe:	e022                	sd	s0,0(sp)
    80002cc0:	0800                	add	s0,sp,16
  return fork();
    80002cc2:	fffff097          	auipc	ra,0xfffff
    80002cc6:	13e080e7          	jalr	318(ra) # 80001e00 <fork>
}
    80002cca:	60a2                	ld	ra,8(sp)
    80002ccc:	6402                	ld	s0,0(sp)
    80002cce:	0141                	add	sp,sp,16
    80002cd0:	8082                	ret

0000000080002cd2 <sys_wait>:

uint64
sys_wait(void)
{
    80002cd2:	1101                	add	sp,sp,-32
    80002cd4:	ec06                	sd	ra,24(sp)
    80002cd6:	e822                	sd	s0,16(sp)
    80002cd8:	1000                	add	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002cda:	fe840593          	add	a1,s0,-24
    80002cde:	4501                	li	a0,0
    80002ce0:	00000097          	auipc	ra,0x0
    80002ce4:	ed0080e7          	jalr	-304(ra) # 80002bb0 <argaddr>
  return wait(p);
    80002ce8:	fe843503          	ld	a0,-24(s0)
    80002cec:	fffff097          	auipc	ra,0xfffff
    80002cf0:	6f4080e7          	jalr	1780(ra) # 800023e0 <wait>
}
    80002cf4:	60e2                	ld	ra,24(sp)
    80002cf6:	6442                	ld	s0,16(sp)
    80002cf8:	6105                	add	sp,sp,32
    80002cfa:	8082                	ret

0000000080002cfc <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002cfc:	7179                	add	sp,sp,-48
    80002cfe:	f406                	sd	ra,40(sp)
    80002d00:	f022                	sd	s0,32(sp)
    80002d02:	ec26                	sd	s1,24(sp)
    80002d04:	1800                	add	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002d06:	fdc40593          	add	a1,s0,-36
    80002d0a:	4501                	li	a0,0
    80002d0c:	00000097          	auipc	ra,0x0
    80002d10:	e84080e7          	jalr	-380(ra) # 80002b90 <argint>
  addr = myproc()->sz;
    80002d14:	fffff097          	auipc	ra,0xfffff
    80002d18:	d36080e7          	jalr	-714(ra) # 80001a4a <myproc>
    80002d1c:	7124                	ld	s1,96(a0)
  if(growproc(n) < 0)
    80002d1e:	fdc42503          	lw	a0,-36(s0)
    80002d22:	fffff097          	auipc	ra,0xfffff
    80002d26:	082080e7          	jalr	130(ra) # 80001da4 <growproc>
    80002d2a:	00054863          	bltz	a0,80002d3a <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002d2e:	8526                	mv	a0,s1
    80002d30:	70a2                	ld	ra,40(sp)
    80002d32:	7402                	ld	s0,32(sp)
    80002d34:	64e2                	ld	s1,24(sp)
    80002d36:	6145                	add	sp,sp,48
    80002d38:	8082                	ret
    return -1;
    80002d3a:	54fd                	li	s1,-1
    80002d3c:	bfcd                	j	80002d2e <sys_sbrk+0x32>

0000000080002d3e <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d3e:	7139                	add	sp,sp,-64
    80002d40:	fc06                	sd	ra,56(sp)
    80002d42:	f822                	sd	s0,48(sp)
    80002d44:	f04a                	sd	s2,32(sp)
    80002d46:	0080                	add	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002d48:	fcc40593          	add	a1,s0,-52
    80002d4c:	4501                	li	a0,0
    80002d4e:	00000097          	auipc	ra,0x0
    80002d52:	e42080e7          	jalr	-446(ra) # 80002b90 <argint>
  acquire(&tickslock);
    80002d56:	00017517          	auipc	a0,0x17
    80002d5a:	bba50513          	add	a0,a0,-1094 # 80019910 <tickslock>
    80002d5e:	ffffe097          	auipc	ra,0xffffe
    80002d62:	eda080e7          	jalr	-294(ra) # 80000c38 <acquire>
  ticks0 = ticks;
    80002d66:	00008917          	auipc	s2,0x8
    80002d6a:	50a92903          	lw	s2,1290(s2) # 8000b270 <ticks>
  while(ticks - ticks0 < n){
    80002d6e:	fcc42783          	lw	a5,-52(s0)
    80002d72:	c3b9                	beqz	a5,80002db8 <sys_sleep+0x7a>
    80002d74:	f426                	sd	s1,40(sp)
    80002d76:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d78:	00017997          	auipc	s3,0x17
    80002d7c:	b9898993          	add	s3,s3,-1128 # 80019910 <tickslock>
    80002d80:	00008497          	auipc	s1,0x8
    80002d84:	4f048493          	add	s1,s1,1264 # 8000b270 <ticks>
    if(killed(myproc())){
    80002d88:	fffff097          	auipc	ra,0xfffff
    80002d8c:	cc2080e7          	jalr	-830(ra) # 80001a4a <myproc>
    80002d90:	fffff097          	auipc	ra,0xfffff
    80002d94:	61e080e7          	jalr	1566(ra) # 800023ae <killed>
    80002d98:	ed15                	bnez	a0,80002dd4 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002d9a:	85ce                	mv	a1,s3
    80002d9c:	8526                	mv	a0,s1
    80002d9e:	fffff097          	auipc	ra,0xfffff
    80002da2:	362080e7          	jalr	866(ra) # 80002100 <sleep>
  while(ticks - ticks0 < n){
    80002da6:	409c                	lw	a5,0(s1)
    80002da8:	412787bb          	subw	a5,a5,s2
    80002dac:	fcc42703          	lw	a4,-52(s0)
    80002db0:	fce7ece3          	bltu	a5,a4,80002d88 <sys_sleep+0x4a>
    80002db4:	74a2                	ld	s1,40(sp)
    80002db6:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002db8:	00017517          	auipc	a0,0x17
    80002dbc:	b5850513          	add	a0,a0,-1192 # 80019910 <tickslock>
    80002dc0:	ffffe097          	auipc	ra,0xffffe
    80002dc4:	f2c080e7          	jalr	-212(ra) # 80000cec <release>
  return 0;
    80002dc8:	4501                	li	a0,0
}
    80002dca:	70e2                	ld	ra,56(sp)
    80002dcc:	7442                	ld	s0,48(sp)
    80002dce:	7902                	ld	s2,32(sp)
    80002dd0:	6121                	add	sp,sp,64
    80002dd2:	8082                	ret
      release(&tickslock);
    80002dd4:	00017517          	auipc	a0,0x17
    80002dd8:	b3c50513          	add	a0,a0,-1220 # 80019910 <tickslock>
    80002ddc:	ffffe097          	auipc	ra,0xffffe
    80002de0:	f10080e7          	jalr	-240(ra) # 80000cec <release>
      return -1;
    80002de4:	557d                	li	a0,-1
    80002de6:	74a2                	ld	s1,40(sp)
    80002de8:	69e2                	ld	s3,24(sp)
    80002dea:	b7c5                	j	80002dca <sys_sleep+0x8c>

0000000080002dec <sys_kill>:

uint64
sys_kill(void)
{
    80002dec:	1101                	add	sp,sp,-32
    80002dee:	ec06                	sd	ra,24(sp)
    80002df0:	e822                	sd	s0,16(sp)
    80002df2:	1000                	add	s0,sp,32
  int pid;

  argint(0, &pid);
    80002df4:	fec40593          	add	a1,s0,-20
    80002df8:	4501                	li	a0,0
    80002dfa:	00000097          	auipc	ra,0x0
    80002dfe:	d96080e7          	jalr	-618(ra) # 80002b90 <argint>
  return kill(pid);
    80002e02:	fec42503          	lw	a0,-20(s0)
    80002e06:	fffff097          	auipc	ra,0xfffff
    80002e0a:	50a080e7          	jalr	1290(ra) # 80002310 <kill>
}
    80002e0e:	60e2                	ld	ra,24(sp)
    80002e10:	6442                	ld	s0,16(sp)
    80002e12:	6105                	add	sp,sp,32
    80002e14:	8082                	ret

0000000080002e16 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e16:	1101                	add	sp,sp,-32
    80002e18:	ec06                	sd	ra,24(sp)
    80002e1a:	e822                	sd	s0,16(sp)
    80002e1c:	e426                	sd	s1,8(sp)
    80002e1e:	1000                	add	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e20:	00017517          	auipc	a0,0x17
    80002e24:	af050513          	add	a0,a0,-1296 # 80019910 <tickslock>
    80002e28:	ffffe097          	auipc	ra,0xffffe
    80002e2c:	e10080e7          	jalr	-496(ra) # 80000c38 <acquire>
  xticks = ticks;
    80002e30:	00008497          	auipc	s1,0x8
    80002e34:	4404a483          	lw	s1,1088(s1) # 8000b270 <ticks>
  release(&tickslock);
    80002e38:	00017517          	auipc	a0,0x17
    80002e3c:	ad850513          	add	a0,a0,-1320 # 80019910 <tickslock>
    80002e40:	ffffe097          	auipc	ra,0xffffe
    80002e44:	eac080e7          	jalr	-340(ra) # 80000cec <release>
  return xticks;
}
    80002e48:	02049513          	sll	a0,s1,0x20
    80002e4c:	9101                	srl	a0,a0,0x20
    80002e4e:	60e2                	ld	ra,24(sp)
    80002e50:	6442                	ld	s0,16(sp)
    80002e52:	64a2                	ld	s1,8(sp)
    80002e54:	6105                	add	sp,sp,32
    80002e56:	8082                	ret

0000000080002e58 <sys_getppid>:

uint64 
sys_getppid(void) {
    80002e58:	1141                	add	sp,sp,-16
    80002e5a:	e406                	sd	ra,8(sp)
    80002e5c:	e022                	sd	s0,0(sp)
    80002e5e:	0800                	add	s0,sp,16
  struct proc *current_proc = myproc(); // (1) call myproc() to get the caller’s struct proc
    80002e60:	fffff097          	auipc	ra,0xfffff
    80002e64:	bea080e7          	jalr	-1046(ra) # 80001a4a <myproc>
  if (current_proc == 0) return -1; // Return an error or invalid PID if no current process is found
    80002e68:	c901                	beqz	a0,80002e78 <sys_getppid+0x20>
  
  struct proc *parent_proc = current_proc->parent; // (2) follow the field “parent” in the struct proc to find the parent’s struct proc
    80002e6a:	693c                	ld	a5,80(a0)
  if (parent_proc == 0) return -1; // Return an error or invalid PID if no parent process is found
    80002e6c:	cb81                	beqz	a5,80002e7c <sys_getppid+0x24>
  
  uint64 parent_pid = parent_proc->pid; // (3) in the parent’s struct proc, find the pid and return it
    80002e6e:	5b88                	lw	a0,48(a5)
  return parent_pid;
}
    80002e70:	60a2                	ld	ra,8(sp)
    80002e72:	6402                	ld	s0,0(sp)
    80002e74:	0141                	add	sp,sp,16
    80002e76:	8082                	ret
  if (current_proc == 0) return -1; // Return an error or invalid PID if no current process is found
    80002e78:	557d                	li	a0,-1
    80002e7a:	bfdd                	j	80002e70 <sys_getppid+0x18>
  if (parent_proc == 0) return -1; // Return an error or invalid PID if no parent process is found
    80002e7c:	557d                	li	a0,-1
    80002e7e:	bfcd                	j	80002e70 <sys_getppid+0x18>

0000000080002e80 <sys_ps>:


extern struct proc proc[NPROC]; //declare array proc which is defined in proc.c already
uint64
sys_ps(void){
    80002e80:	7165                	add	sp,sp,-400
    80002e82:	e706                	sd	ra,392(sp)
    80002e84:	e322                	sd	s0,384(sp)
    80002e86:	fea6                	sd	s1,376(sp)
    80002e88:	faca                	sd	s2,368(sp)
    80002e8a:	f6ce                	sd	s3,360(sp)
    80002e8c:	f2d2                	sd	s4,352(sp)
    80002e8e:	eed6                	sd	s5,344(sp)
    80002e90:	eada                	sd	s6,336(sp)
    80002e92:	e6de                	sd	s7,328(sp)
    80002e94:	e2e2                	sd	s8,320(sp)
    80002e96:	fe66                	sd	s9,312(sp)
    80002e98:	fa6a                	sd	s10,304(sp)
    80002e9a:	f66e                	sd	s11,296(sp)
    80002e9c:	0b00                	add	s0,sp,400
    80002e9e:	81010113          	add	sp,sp,-2032
    [RUNNABLE]  "runble",
    [RUNNING]   "run   ",
    [ZOMBIE]    "zombie"
};

for (int i = 0; i < NPROC; i++) {
    80002ea2:	00011497          	auipc	s1,0x11
    80002ea6:	bde48493          	add	s1,s1,-1058 # 80013a80 <proc+0x170>
    80002eaa:	00017b97          	auipc	s7,0x17
    80002eae:	bd6b8b93          	add	s7,s7,-1066 # 80019a80 <bcache+0x158>
  int numProc = 0; //variable keeping track of the number of processes in the system
    80002eb2:	4901                	li	s2,0
  if (proc[i].state != UNUSED) {
    ps[numProc].pid = proc[i].pid;
    80002eb4:	7a7d                	lui	s4,0xfffff
    80002eb6:	f90a0793          	add	a5,s4,-112 # ffffffffffffef90 <end+0xffffffff7ffda2a0>
    80002eba:	00878a33          	add	s4,a5,s0
    ps[numProc].ppid = proc[i].parent ? proc[i].parent->pid : -1; // Assuming parent is a pointer to the parent proc struct
    80002ebe:	5cfd                	li	s9,-1
    // Correctly map the numeric state to its string representation
    if(proc[i].state >= 0 && proc[i].state < NELEM(states) && states[proc[i].state]) {
    80002ec0:	4c15                	li	s8,5
    } else {
        strncpy(ps[numProc].state, "???", sizeof(ps[numProc].state) - 1);
        ps[numProc].state[sizeof(ps[numProc].state) - 1] = '\0'; // Ensure null-termination for safety
    }

    strncpy(ps[numProc].name, proc[i].name, sizeof(ps[numProc].name) - 1);
    80002ec2:	7b7d                	lui	s6,0xfffff
    80002ec4:	690b0793          	add	a5,s6,1680 # fffffffffffff690 <end+0xffffffff7ffda9a0>
    80002ec8:	00878b33          	add	s6,a5,s0
        strncpy(ps[numProc].state, "???", sizeof(ps[numProc].state) - 1);
    80002ecc:	00005d97          	auipc	s11,0x5
    80002ed0:	3a4d8d93          	add	s11,s11,932 # 80008270 <digits+0x240>
    if(proc[i].state >= 0 && proc[i].state < NELEM(states) && states[proc[i].state]) {
    80002ed4:	00005d17          	auipc	s10,0x5
    80002ed8:	634d0d13          	add	s10,s10,1588 # 80008508 <states.0>
    80002edc:	a0b1                	j	80002f28 <sys_ps+0xa8>
        strncpy(ps[numProc].state, "???", sizeof(ps[numProc].state) - 1);
    80002ede:	00391513          	sll	a0,s2,0x3
    80002ee2:	954a                	add	a0,a0,s2
    80002ee4:	050a                	sll	a0,a0,0x2
    80002ee6:	0521                	add	a0,a0,8
    80002ee8:	4625                	li	a2,9
    80002eea:	85ee                	mv	a1,s11
    80002eec:	955a                	add	a0,a0,s6
    80002eee:	ffffe097          	auipc	ra,0xffffe
    80002ef2:	f4c080e7          	jalr	-180(ra) # 80000e3a <strncpy>
        ps[numProc].state[sizeof(ps[numProc].state) - 1] = '\0'; // Ensure null-termination
    80002ef6:	00391513          	sll	a0,s2,0x3
    80002efa:	012509b3          	add	s3,a0,s2
    80002efe:	098a                	sll	s3,s3,0x2
    80002f00:	99d2                	add	s3,s3,s4
    80002f02:	700988a3          	sb	zero,1809(s3)
    strncpy(ps[numProc].name, proc[i].name, sizeof(ps[numProc].name) - 1);
    80002f06:	954a                	add	a0,a0,s2
    80002f08:	050a                	sll	a0,a0,0x2
    80002f0a:	0549                	add	a0,a0,18
    80002f0c:	463d                	li	a2,15
    80002f0e:	85d6                	mv	a1,s5
    80002f10:	955a                	add	a0,a0,s6
    80002f12:	ffffe097          	auipc	ra,0xffffe
    80002f16:	f28080e7          	jalr	-216(ra) # 80000e3a <strncpy>
    ps[numProc].name[sizeof(ps[numProc].name) - 1] = '\0'; // Ensure null-termination for the name as well
    80002f1a:	720980a3          	sb	zero,1825(s3)

    numProc++;
    80002f1e:	2905                	addw	s2,s2,1
for (int i = 0; i < NPROC; i++) {
    80002f20:	18048493          	add	s1,s1,384
    80002f24:	07748063          	beq	s1,s7,80002f84 <sys_ps+0x104>
  if (proc[i].state != UNUSED) {
    80002f28:	8aa6                	mv	s5,s1
    80002f2a:	ea84a783          	lw	a5,-344(s1)
    80002f2e:	dbed                	beqz	a5,80002f20 <sys_ps+0xa0>
    ps[numProc].pid = proc[i].pid;
    80002f30:	00391713          	sll	a4,s2,0x3
    80002f34:	974a                	add	a4,a4,s2
    80002f36:	070a                	sll	a4,a4,0x2
    80002f38:	9752                	add	a4,a4,s4
    80002f3a:	ec04a683          	lw	a3,-320(s1)
    80002f3e:	70d72023          	sw	a3,1792(a4)
    ps[numProc].ppid = proc[i].parent ? proc[i].parent->pid : -1; // Assuming parent is a pointer to the parent proc struct
    80002f42:	ee04b703          	ld	a4,-288(s1)
    80002f46:	86e6                	mv	a3,s9
    80002f48:	c311                	beqz	a4,80002f4c <sys_ps+0xcc>
    80002f4a:	5b14                	lw	a3,48(a4)
    80002f4c:	00391713          	sll	a4,s2,0x3
    80002f50:	974a                	add	a4,a4,s2
    80002f52:	070a                	sll	a4,a4,0x2
    80002f54:	9752                	add	a4,a4,s4
    80002f56:	70d72223          	sw	a3,1796(a4)
    if(proc[i].state >= 0 && proc[i].state < NELEM(states) && states[proc[i].state]) {
    80002f5a:	f8fc62e3          	bltu	s8,a5,80002ede <sys_ps+0x5e>
    80002f5e:	02079713          	sll	a4,a5,0x20
    80002f62:	01d75793          	srl	a5,a4,0x1d
    80002f66:	97ea                	add	a5,a5,s10
    80002f68:	638c                	ld	a1,0(a5)
    80002f6a:	d9b5                	beqz	a1,80002ede <sys_ps+0x5e>
        strncpy(ps[numProc].state, states[proc[i].state], sizeof(ps[numProc].state) - 1);
    80002f6c:	00391513          	sll	a0,s2,0x3
    80002f70:	954a                	add	a0,a0,s2
    80002f72:	050a                	sll	a0,a0,0x2
    80002f74:	0521                	add	a0,a0,8
    80002f76:	4625                	li	a2,9
    80002f78:	955a                	add	a0,a0,s6
    80002f7a:	ffffe097          	auipc	ra,0xffffe
    80002f7e:	ec0080e7          	jalr	-320(ra) # 80000e3a <strncpy>
        ps[numProc].state[sizeof(ps[numProc].state) - 1] = '\0'; // Ensure null-termination
    80002f82:	bf95                	j	80002ef6 <sys_ps+0x76>
  }
}


  uint64 arg_addr;
  argaddr(0, &arg_addr);
    80002f84:	75fd                	lui	a1,0xfffff
    80002f86:	68858793          	add	a5,a1,1672 # fffffffffffff688 <end+0xffffffff7ffda998>
    80002f8a:	008785b3          	add	a1,a5,s0
    80002f8e:	4501                	li	a0,0
    80002f90:	00000097          	auipc	ra,0x0
    80002f94:	c20080e7          	jalr	-992(ra) # 80002bb0 <argaddr>
  //copy array ps to the saved address
  if (copyout(myproc()->pagetable,
    80002f98:	fffff097          	auipc	ra,0xfffff
    80002f9c:	ab2080e7          	jalr	-1358(ra) # 80001a4a <myproc>
    80002fa0:	84ca                	mv	s1,s2
    80002fa2:	00391693          	sll	a3,s2,0x3
    80002fa6:	96ca                	add	a3,a3,s2
    80002fa8:	767d                	lui	a2,0xfffff
    80002faa:	77fd                	lui	a5,0xfffff
    80002fac:	068a                	sll	a3,a3,0x2
    80002fae:	69060713          	add	a4,a2,1680 # fffffffffffff690 <end+0xffffffff7ffda9a0>
    80002fb2:	00870633          	add	a2,a4,s0
    80002fb6:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffda2a0>
    80002fba:	97a2                	add	a5,a5,s0
    80002fbc:	6f87b583          	ld	a1,1784(a5)
    80002fc0:	7528                	ld	a0,104(a0)
    80002fc2:	ffffe097          	auipc	ra,0xffffe
    80002fc6:	720080e7          	jalr	1824(ra) # 800016e2 <copyout>
    80002fca:	02054463          	bltz	a0,80002ff2 <sys_ps+0x172>
  (char *)ps,
  numProc*sizeof(struct ps_struct)) < 0)
  return -1;
  //return numProc as well
  return numProc;
}
    80002fce:	8526                	mv	a0,s1
    80002fd0:	7f010113          	add	sp,sp,2032
    80002fd4:	60ba                	ld	ra,392(sp)
    80002fd6:	641a                	ld	s0,384(sp)
    80002fd8:	74f6                	ld	s1,376(sp)
    80002fda:	7956                	ld	s2,368(sp)
    80002fdc:	79b6                	ld	s3,360(sp)
    80002fde:	7a16                	ld	s4,352(sp)
    80002fe0:	6af6                	ld	s5,344(sp)
    80002fe2:	6b56                	ld	s6,336(sp)
    80002fe4:	6bb6                	ld	s7,328(sp)
    80002fe6:	6c16                	ld	s8,320(sp)
    80002fe8:	7cf2                	ld	s9,312(sp)
    80002fea:	7d52                	ld	s10,304(sp)
    80002fec:	7db2                	ld	s11,296(sp)
    80002fee:	6159                	add	sp,sp,400
    80002ff0:	8082                	ret
  return -1;
    80002ff2:	54fd                	li	s1,-1
    80002ff4:	bfe9                	j	80002fce <sys_ps+0x14e>

0000000080002ff6 <sys_getschedhistory>:

uint64
sys_getschedhistory(void){
    80002ff6:	7139                	add	sp,sp,-64
    80002ff8:	fc06                	sd	ra,56(sp)
    80002ffa:	f822                	sd	s0,48(sp)
    80002ffc:	0080                	add	s0,sp,64
    int trapCount;
    int sleepCount;
  } my_history;

  // Retrieve the current process's information
  struct proc *p = myproc();
    80002ffe:	fffff097          	auipc	ra,0xfffff
    80003002:	a4c080e7          	jalr	-1460(ra) # 80001a4a <myproc>
  if (p == 0) return -1; // Error if no current process
    80003006:	cd31                	beqz	a0,80003062 <sys_getschedhistory+0x6c>
    80003008:	f426                	sd	s1,40(sp)
    8000300a:	84aa                	mv	s1,a0

  // Populate my_history with the current process's scheduling history
  my_history.runCount = p->runCount;
    8000300c:	595c                	lw	a5,52(a0)
    8000300e:	fcf42423          	sw	a5,-56(s0)
  my_history.systemcallCount = p->systemcallCount;
    80003012:	5d1c                	lw	a5,56(a0)
    80003014:	fcf42623          	sw	a5,-52(s0)
  my_history.interruptCount = p->interruptCount;
    80003018:	5d5c                	lw	a5,60(a0)
    8000301a:	fcf42823          	sw	a5,-48(s0)
  my_history.preemptCount = p->preemptCount;
    8000301e:	413c                	lw	a5,64(a0)
    80003020:	fcf42a23          	sw	a5,-44(s0)
  my_history.trapCount = p->trapCount;
    80003024:	417c                	lw	a5,68(a0)
    80003026:	fcf42c23          	sw	a5,-40(s0)
  my_history.sleepCount = p->sleepCount;
    8000302a:	453c                	lw	a5,72(a0)
    8000302c:	fcf42e23          	sw	a5,-36(s0)

  // Save the address of the user space argument to arg_addr
  uint64 arg_addr;
  argaddr(0, &arg_addr);
    80003030:	fc040593          	add	a1,s0,-64
    80003034:	4501                	li	a0,0
    80003036:	00000097          	auipc	ra,0x0
    8000303a:	b7a080e7          	jalr	-1158(ra) # 80002bb0 <argaddr>

  // Copy the content in my_history to the saved address
  if (copyout(p->pagetable, arg_addr, (char *)&my_history, sizeof(struct sched_history)) < 0)
    8000303e:	46e1                	li	a3,24
    80003040:	fc840613          	add	a2,s0,-56
    80003044:	fc043583          	ld	a1,-64(s0)
    80003048:	74a8                	ld	a0,104(s1)
    8000304a:	ffffe097          	auipc	ra,0xffffe
    8000304e:	698080e7          	jalr	1688(ra) # 800016e2 <copyout>
    80003052:	00054a63          	bltz	a0,80003066 <sys_getschedhistory+0x70>
    return -1;

  // Successfully copied, return the pid as well
  return p->pid; // Corrected to return the PID at the end of the function
    80003056:	5888                	lw	a0,48(s1)
    80003058:	74a2                	ld	s1,40(sp)
}
    8000305a:	70e2                	ld	ra,56(sp)
    8000305c:	7442                	ld	s0,48(sp)
    8000305e:	6121                	add	sp,sp,64
    80003060:	8082                	ret
  if (p == 0) return -1; // Error if no current process
    80003062:	557d                	li	a0,-1
    80003064:	bfdd                	j	8000305a <sys_getschedhistory+0x64>
    return -1;
    80003066:	557d                	li	a0,-1
    80003068:	74a2                	ld	s1,40(sp)
    8000306a:	bfc5                	j	8000305a <sys_getschedhistory+0x64>

000000008000306c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000306c:	7179                	add	sp,sp,-48
    8000306e:	f406                	sd	ra,40(sp)
    80003070:	f022                	sd	s0,32(sp)
    80003072:	ec26                	sd	s1,24(sp)
    80003074:	e84a                	sd	s2,16(sp)
    80003076:	e44e                	sd	s3,8(sp)
    80003078:	e052                	sd	s4,0(sp)
    8000307a:	1800                	add	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000307c:	00005597          	auipc	a1,0x5
    80003080:	4bc58593          	add	a1,a1,1212 # 80008538 <states.0+0x30>
    80003084:	00017517          	auipc	a0,0x17
    80003088:	8a450513          	add	a0,a0,-1884 # 80019928 <bcache>
    8000308c:	ffffe097          	auipc	ra,0xffffe
    80003090:	b1c080e7          	jalr	-1252(ra) # 80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003094:	0001f797          	auipc	a5,0x1f
    80003098:	89478793          	add	a5,a5,-1900 # 80021928 <bcache+0x8000>
    8000309c:	0001f717          	auipc	a4,0x1f
    800030a0:	af470713          	add	a4,a4,-1292 # 80021b90 <bcache+0x8268>
    800030a4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800030a8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030ac:	00017497          	auipc	s1,0x17
    800030b0:	89448493          	add	s1,s1,-1900 # 80019940 <bcache+0x18>
    b->next = bcache.head.next;
    800030b4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030b6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030b8:	00005a17          	auipc	s4,0x5
    800030bc:	488a0a13          	add	s4,s4,1160 # 80008540 <states.0+0x38>
    b->next = bcache.head.next;
    800030c0:	2b893783          	ld	a5,696(s2)
    800030c4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800030c6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800030ca:	85d2                	mv	a1,s4
    800030cc:	01048513          	add	a0,s1,16
    800030d0:	00001097          	auipc	ra,0x1
    800030d4:	4e8080e7          	jalr	1256(ra) # 800045b8 <initsleeplock>
    bcache.head.next->prev = b;
    800030d8:	2b893783          	ld	a5,696(s2)
    800030dc:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030de:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030e2:	45848493          	add	s1,s1,1112
    800030e6:	fd349de3          	bne	s1,s3,800030c0 <binit+0x54>
  }
}
    800030ea:	70a2                	ld	ra,40(sp)
    800030ec:	7402                	ld	s0,32(sp)
    800030ee:	64e2                	ld	s1,24(sp)
    800030f0:	6942                	ld	s2,16(sp)
    800030f2:	69a2                	ld	s3,8(sp)
    800030f4:	6a02                	ld	s4,0(sp)
    800030f6:	6145                	add	sp,sp,48
    800030f8:	8082                	ret

00000000800030fa <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800030fa:	7179                	add	sp,sp,-48
    800030fc:	f406                	sd	ra,40(sp)
    800030fe:	f022                	sd	s0,32(sp)
    80003100:	ec26                	sd	s1,24(sp)
    80003102:	e84a                	sd	s2,16(sp)
    80003104:	e44e                	sd	s3,8(sp)
    80003106:	1800                	add	s0,sp,48
    80003108:	892a                	mv	s2,a0
    8000310a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000310c:	00017517          	auipc	a0,0x17
    80003110:	81c50513          	add	a0,a0,-2020 # 80019928 <bcache>
    80003114:	ffffe097          	auipc	ra,0xffffe
    80003118:	b24080e7          	jalr	-1244(ra) # 80000c38 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000311c:	0001f497          	auipc	s1,0x1f
    80003120:	ac44b483          	ld	s1,-1340(s1) # 80021be0 <bcache+0x82b8>
    80003124:	0001f797          	auipc	a5,0x1f
    80003128:	a6c78793          	add	a5,a5,-1428 # 80021b90 <bcache+0x8268>
    8000312c:	02f48f63          	beq	s1,a5,8000316a <bread+0x70>
    80003130:	873e                	mv	a4,a5
    80003132:	a021                	j	8000313a <bread+0x40>
    80003134:	68a4                	ld	s1,80(s1)
    80003136:	02e48a63          	beq	s1,a4,8000316a <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000313a:	449c                	lw	a5,8(s1)
    8000313c:	ff279ce3          	bne	a5,s2,80003134 <bread+0x3a>
    80003140:	44dc                	lw	a5,12(s1)
    80003142:	ff3799e3          	bne	a5,s3,80003134 <bread+0x3a>
      b->refcnt++;
    80003146:	40bc                	lw	a5,64(s1)
    80003148:	2785                	addw	a5,a5,1
    8000314a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000314c:	00016517          	auipc	a0,0x16
    80003150:	7dc50513          	add	a0,a0,2012 # 80019928 <bcache>
    80003154:	ffffe097          	auipc	ra,0xffffe
    80003158:	b98080e7          	jalr	-1128(ra) # 80000cec <release>
      acquiresleep(&b->lock);
    8000315c:	01048513          	add	a0,s1,16
    80003160:	00001097          	auipc	ra,0x1
    80003164:	492080e7          	jalr	1170(ra) # 800045f2 <acquiresleep>
      return b;
    80003168:	a8b9                	j	800031c6 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000316a:	0001f497          	auipc	s1,0x1f
    8000316e:	a6e4b483          	ld	s1,-1426(s1) # 80021bd8 <bcache+0x82b0>
    80003172:	0001f797          	auipc	a5,0x1f
    80003176:	a1e78793          	add	a5,a5,-1506 # 80021b90 <bcache+0x8268>
    8000317a:	00f48863          	beq	s1,a5,8000318a <bread+0x90>
    8000317e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003180:	40bc                	lw	a5,64(s1)
    80003182:	cf81                	beqz	a5,8000319a <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003184:	64a4                	ld	s1,72(s1)
    80003186:	fee49de3          	bne	s1,a4,80003180 <bread+0x86>
  panic("bget: no buffers");
    8000318a:	00005517          	auipc	a0,0x5
    8000318e:	3be50513          	add	a0,a0,958 # 80008548 <states.0+0x40>
    80003192:	ffffd097          	auipc	ra,0xffffd
    80003196:	3ce080e7          	jalr	974(ra) # 80000560 <panic>
      b->dev = dev;
    8000319a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000319e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800031a2:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031a6:	4785                	li	a5,1
    800031a8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031aa:	00016517          	auipc	a0,0x16
    800031ae:	77e50513          	add	a0,a0,1918 # 80019928 <bcache>
    800031b2:	ffffe097          	auipc	ra,0xffffe
    800031b6:	b3a080e7          	jalr	-1222(ra) # 80000cec <release>
      acquiresleep(&b->lock);
    800031ba:	01048513          	add	a0,s1,16
    800031be:	00001097          	auipc	ra,0x1
    800031c2:	434080e7          	jalr	1076(ra) # 800045f2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031c6:	409c                	lw	a5,0(s1)
    800031c8:	cb89                	beqz	a5,800031da <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031ca:	8526                	mv	a0,s1
    800031cc:	70a2                	ld	ra,40(sp)
    800031ce:	7402                	ld	s0,32(sp)
    800031d0:	64e2                	ld	s1,24(sp)
    800031d2:	6942                	ld	s2,16(sp)
    800031d4:	69a2                	ld	s3,8(sp)
    800031d6:	6145                	add	sp,sp,48
    800031d8:	8082                	ret
    virtio_disk_rw(b, 0);
    800031da:	4581                	li	a1,0
    800031dc:	8526                	mv	a0,s1
    800031de:	00003097          	auipc	ra,0x3
    800031e2:	0fa080e7          	jalr	250(ra) # 800062d8 <virtio_disk_rw>
    b->valid = 1;
    800031e6:	4785                	li	a5,1
    800031e8:	c09c                	sw	a5,0(s1)
  return b;
    800031ea:	b7c5                	j	800031ca <bread+0xd0>

00000000800031ec <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800031ec:	1101                	add	sp,sp,-32
    800031ee:	ec06                	sd	ra,24(sp)
    800031f0:	e822                	sd	s0,16(sp)
    800031f2:	e426                	sd	s1,8(sp)
    800031f4:	1000                	add	s0,sp,32
    800031f6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031f8:	0541                	add	a0,a0,16
    800031fa:	00001097          	auipc	ra,0x1
    800031fe:	492080e7          	jalr	1170(ra) # 8000468c <holdingsleep>
    80003202:	cd01                	beqz	a0,8000321a <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003204:	4585                	li	a1,1
    80003206:	8526                	mv	a0,s1
    80003208:	00003097          	auipc	ra,0x3
    8000320c:	0d0080e7          	jalr	208(ra) # 800062d8 <virtio_disk_rw>
}
    80003210:	60e2                	ld	ra,24(sp)
    80003212:	6442                	ld	s0,16(sp)
    80003214:	64a2                	ld	s1,8(sp)
    80003216:	6105                	add	sp,sp,32
    80003218:	8082                	ret
    panic("bwrite");
    8000321a:	00005517          	auipc	a0,0x5
    8000321e:	34650513          	add	a0,a0,838 # 80008560 <states.0+0x58>
    80003222:	ffffd097          	auipc	ra,0xffffd
    80003226:	33e080e7          	jalr	830(ra) # 80000560 <panic>

000000008000322a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000322a:	1101                	add	sp,sp,-32
    8000322c:	ec06                	sd	ra,24(sp)
    8000322e:	e822                	sd	s0,16(sp)
    80003230:	e426                	sd	s1,8(sp)
    80003232:	e04a                	sd	s2,0(sp)
    80003234:	1000                	add	s0,sp,32
    80003236:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003238:	01050913          	add	s2,a0,16
    8000323c:	854a                	mv	a0,s2
    8000323e:	00001097          	auipc	ra,0x1
    80003242:	44e080e7          	jalr	1102(ra) # 8000468c <holdingsleep>
    80003246:	c925                	beqz	a0,800032b6 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80003248:	854a                	mv	a0,s2
    8000324a:	00001097          	auipc	ra,0x1
    8000324e:	3fe080e7          	jalr	1022(ra) # 80004648 <releasesleep>

  acquire(&bcache.lock);
    80003252:	00016517          	auipc	a0,0x16
    80003256:	6d650513          	add	a0,a0,1750 # 80019928 <bcache>
    8000325a:	ffffe097          	auipc	ra,0xffffe
    8000325e:	9de080e7          	jalr	-1570(ra) # 80000c38 <acquire>
  b->refcnt--;
    80003262:	40bc                	lw	a5,64(s1)
    80003264:	37fd                	addw	a5,a5,-1
    80003266:	0007871b          	sext.w	a4,a5
    8000326a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000326c:	e71d                	bnez	a4,8000329a <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000326e:	68b8                	ld	a4,80(s1)
    80003270:	64bc                	ld	a5,72(s1)
    80003272:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003274:	68b8                	ld	a4,80(s1)
    80003276:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003278:	0001e797          	auipc	a5,0x1e
    8000327c:	6b078793          	add	a5,a5,1712 # 80021928 <bcache+0x8000>
    80003280:	2b87b703          	ld	a4,696(a5)
    80003284:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003286:	0001f717          	auipc	a4,0x1f
    8000328a:	90a70713          	add	a4,a4,-1782 # 80021b90 <bcache+0x8268>
    8000328e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003290:	2b87b703          	ld	a4,696(a5)
    80003294:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003296:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000329a:	00016517          	auipc	a0,0x16
    8000329e:	68e50513          	add	a0,a0,1678 # 80019928 <bcache>
    800032a2:	ffffe097          	auipc	ra,0xffffe
    800032a6:	a4a080e7          	jalr	-1462(ra) # 80000cec <release>
}
    800032aa:	60e2                	ld	ra,24(sp)
    800032ac:	6442                	ld	s0,16(sp)
    800032ae:	64a2                	ld	s1,8(sp)
    800032b0:	6902                	ld	s2,0(sp)
    800032b2:	6105                	add	sp,sp,32
    800032b4:	8082                	ret
    panic("brelse");
    800032b6:	00005517          	auipc	a0,0x5
    800032ba:	2b250513          	add	a0,a0,690 # 80008568 <states.0+0x60>
    800032be:	ffffd097          	auipc	ra,0xffffd
    800032c2:	2a2080e7          	jalr	674(ra) # 80000560 <panic>

00000000800032c6 <bpin>:

void
bpin(struct buf *b) {
    800032c6:	1101                	add	sp,sp,-32
    800032c8:	ec06                	sd	ra,24(sp)
    800032ca:	e822                	sd	s0,16(sp)
    800032cc:	e426                	sd	s1,8(sp)
    800032ce:	1000                	add	s0,sp,32
    800032d0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032d2:	00016517          	auipc	a0,0x16
    800032d6:	65650513          	add	a0,a0,1622 # 80019928 <bcache>
    800032da:	ffffe097          	auipc	ra,0xffffe
    800032de:	95e080e7          	jalr	-1698(ra) # 80000c38 <acquire>
  b->refcnt++;
    800032e2:	40bc                	lw	a5,64(s1)
    800032e4:	2785                	addw	a5,a5,1
    800032e6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032e8:	00016517          	auipc	a0,0x16
    800032ec:	64050513          	add	a0,a0,1600 # 80019928 <bcache>
    800032f0:	ffffe097          	auipc	ra,0xffffe
    800032f4:	9fc080e7          	jalr	-1540(ra) # 80000cec <release>
}
    800032f8:	60e2                	ld	ra,24(sp)
    800032fa:	6442                	ld	s0,16(sp)
    800032fc:	64a2                	ld	s1,8(sp)
    800032fe:	6105                	add	sp,sp,32
    80003300:	8082                	ret

0000000080003302 <bunpin>:

void
bunpin(struct buf *b) {
    80003302:	1101                	add	sp,sp,-32
    80003304:	ec06                	sd	ra,24(sp)
    80003306:	e822                	sd	s0,16(sp)
    80003308:	e426                	sd	s1,8(sp)
    8000330a:	1000                	add	s0,sp,32
    8000330c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000330e:	00016517          	auipc	a0,0x16
    80003312:	61a50513          	add	a0,a0,1562 # 80019928 <bcache>
    80003316:	ffffe097          	auipc	ra,0xffffe
    8000331a:	922080e7          	jalr	-1758(ra) # 80000c38 <acquire>
  b->refcnt--;
    8000331e:	40bc                	lw	a5,64(s1)
    80003320:	37fd                	addw	a5,a5,-1
    80003322:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003324:	00016517          	auipc	a0,0x16
    80003328:	60450513          	add	a0,a0,1540 # 80019928 <bcache>
    8000332c:	ffffe097          	auipc	ra,0xffffe
    80003330:	9c0080e7          	jalr	-1600(ra) # 80000cec <release>
}
    80003334:	60e2                	ld	ra,24(sp)
    80003336:	6442                	ld	s0,16(sp)
    80003338:	64a2                	ld	s1,8(sp)
    8000333a:	6105                	add	sp,sp,32
    8000333c:	8082                	ret

000000008000333e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000333e:	1101                	add	sp,sp,-32
    80003340:	ec06                	sd	ra,24(sp)
    80003342:	e822                	sd	s0,16(sp)
    80003344:	e426                	sd	s1,8(sp)
    80003346:	e04a                	sd	s2,0(sp)
    80003348:	1000                	add	s0,sp,32
    8000334a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000334c:	00d5d59b          	srlw	a1,a1,0xd
    80003350:	0001f797          	auipc	a5,0x1f
    80003354:	cb47a783          	lw	a5,-844(a5) # 80022004 <sb+0x1c>
    80003358:	9dbd                	addw	a1,a1,a5
    8000335a:	00000097          	auipc	ra,0x0
    8000335e:	da0080e7          	jalr	-608(ra) # 800030fa <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003362:	0074f713          	and	a4,s1,7
    80003366:	4785                	li	a5,1
    80003368:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000336c:	14ce                	sll	s1,s1,0x33
    8000336e:	90d9                	srl	s1,s1,0x36
    80003370:	00950733          	add	a4,a0,s1
    80003374:	05874703          	lbu	a4,88(a4)
    80003378:	00e7f6b3          	and	a3,a5,a4
    8000337c:	c69d                	beqz	a3,800033aa <bfree+0x6c>
    8000337e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003380:	94aa                	add	s1,s1,a0
    80003382:	fff7c793          	not	a5,a5
    80003386:	8f7d                	and	a4,a4,a5
    80003388:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000338c:	00001097          	auipc	ra,0x1
    80003390:	148080e7          	jalr	328(ra) # 800044d4 <log_write>
  brelse(bp);
    80003394:	854a                	mv	a0,s2
    80003396:	00000097          	auipc	ra,0x0
    8000339a:	e94080e7          	jalr	-364(ra) # 8000322a <brelse>
}
    8000339e:	60e2                	ld	ra,24(sp)
    800033a0:	6442                	ld	s0,16(sp)
    800033a2:	64a2                	ld	s1,8(sp)
    800033a4:	6902                	ld	s2,0(sp)
    800033a6:	6105                	add	sp,sp,32
    800033a8:	8082                	ret
    panic("freeing free block");
    800033aa:	00005517          	auipc	a0,0x5
    800033ae:	1c650513          	add	a0,a0,454 # 80008570 <states.0+0x68>
    800033b2:	ffffd097          	auipc	ra,0xffffd
    800033b6:	1ae080e7          	jalr	430(ra) # 80000560 <panic>

00000000800033ba <balloc>:
{
    800033ba:	711d                	add	sp,sp,-96
    800033bc:	ec86                	sd	ra,88(sp)
    800033be:	e8a2                	sd	s0,80(sp)
    800033c0:	e4a6                	sd	s1,72(sp)
    800033c2:	1080                	add	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800033c4:	0001f797          	auipc	a5,0x1f
    800033c8:	c287a783          	lw	a5,-984(a5) # 80021fec <sb+0x4>
    800033cc:	10078f63          	beqz	a5,800034ea <balloc+0x130>
    800033d0:	e0ca                	sd	s2,64(sp)
    800033d2:	fc4e                	sd	s3,56(sp)
    800033d4:	f852                	sd	s4,48(sp)
    800033d6:	f456                	sd	s5,40(sp)
    800033d8:	f05a                	sd	s6,32(sp)
    800033da:	ec5e                	sd	s7,24(sp)
    800033dc:	e862                	sd	s8,16(sp)
    800033de:	e466                	sd	s9,8(sp)
    800033e0:	8baa                	mv	s7,a0
    800033e2:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800033e4:	0001fb17          	auipc	s6,0x1f
    800033e8:	c04b0b13          	add	s6,s6,-1020 # 80021fe8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033ec:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800033ee:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033f0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800033f2:	6c89                	lui	s9,0x2
    800033f4:	a061                	j	8000347c <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800033f6:	97ca                	add	a5,a5,s2
    800033f8:	8e55                	or	a2,a2,a3
    800033fa:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800033fe:	854a                	mv	a0,s2
    80003400:	00001097          	auipc	ra,0x1
    80003404:	0d4080e7          	jalr	212(ra) # 800044d4 <log_write>
        brelse(bp);
    80003408:	854a                	mv	a0,s2
    8000340a:	00000097          	auipc	ra,0x0
    8000340e:	e20080e7          	jalr	-480(ra) # 8000322a <brelse>
  bp = bread(dev, bno);
    80003412:	85a6                	mv	a1,s1
    80003414:	855e                	mv	a0,s7
    80003416:	00000097          	auipc	ra,0x0
    8000341a:	ce4080e7          	jalr	-796(ra) # 800030fa <bread>
    8000341e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003420:	40000613          	li	a2,1024
    80003424:	4581                	li	a1,0
    80003426:	05850513          	add	a0,a0,88
    8000342a:	ffffe097          	auipc	ra,0xffffe
    8000342e:	90a080e7          	jalr	-1782(ra) # 80000d34 <memset>
  log_write(bp);
    80003432:	854a                	mv	a0,s2
    80003434:	00001097          	auipc	ra,0x1
    80003438:	0a0080e7          	jalr	160(ra) # 800044d4 <log_write>
  brelse(bp);
    8000343c:	854a                	mv	a0,s2
    8000343e:	00000097          	auipc	ra,0x0
    80003442:	dec080e7          	jalr	-532(ra) # 8000322a <brelse>
}
    80003446:	6906                	ld	s2,64(sp)
    80003448:	79e2                	ld	s3,56(sp)
    8000344a:	7a42                	ld	s4,48(sp)
    8000344c:	7aa2                	ld	s5,40(sp)
    8000344e:	7b02                	ld	s6,32(sp)
    80003450:	6be2                	ld	s7,24(sp)
    80003452:	6c42                	ld	s8,16(sp)
    80003454:	6ca2                	ld	s9,8(sp)
}
    80003456:	8526                	mv	a0,s1
    80003458:	60e6                	ld	ra,88(sp)
    8000345a:	6446                	ld	s0,80(sp)
    8000345c:	64a6                	ld	s1,72(sp)
    8000345e:	6125                	add	sp,sp,96
    80003460:	8082                	ret
    brelse(bp);
    80003462:	854a                	mv	a0,s2
    80003464:	00000097          	auipc	ra,0x0
    80003468:	dc6080e7          	jalr	-570(ra) # 8000322a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000346c:	015c87bb          	addw	a5,s9,s5
    80003470:	00078a9b          	sext.w	s5,a5
    80003474:	004b2703          	lw	a4,4(s6)
    80003478:	06eaf163          	bgeu	s5,a4,800034da <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
    8000347c:	41fad79b          	sraw	a5,s5,0x1f
    80003480:	0137d79b          	srlw	a5,a5,0x13
    80003484:	015787bb          	addw	a5,a5,s5
    80003488:	40d7d79b          	sraw	a5,a5,0xd
    8000348c:	01cb2583          	lw	a1,28(s6)
    80003490:	9dbd                	addw	a1,a1,a5
    80003492:	855e                	mv	a0,s7
    80003494:	00000097          	auipc	ra,0x0
    80003498:	c66080e7          	jalr	-922(ra) # 800030fa <bread>
    8000349c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000349e:	004b2503          	lw	a0,4(s6)
    800034a2:	000a849b          	sext.w	s1,s5
    800034a6:	8762                	mv	a4,s8
    800034a8:	faa4fde3          	bgeu	s1,a0,80003462 <balloc+0xa8>
      m = 1 << (bi % 8);
    800034ac:	00777693          	and	a3,a4,7
    800034b0:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800034b4:	41f7579b          	sraw	a5,a4,0x1f
    800034b8:	01d7d79b          	srlw	a5,a5,0x1d
    800034bc:	9fb9                	addw	a5,a5,a4
    800034be:	4037d79b          	sraw	a5,a5,0x3
    800034c2:	00f90633          	add	a2,s2,a5
    800034c6:	05864603          	lbu	a2,88(a2)
    800034ca:	00c6f5b3          	and	a1,a3,a2
    800034ce:	d585                	beqz	a1,800033f6 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034d0:	2705                	addw	a4,a4,1
    800034d2:	2485                	addw	s1,s1,1
    800034d4:	fd471ae3          	bne	a4,s4,800034a8 <balloc+0xee>
    800034d8:	b769                	j	80003462 <balloc+0xa8>
    800034da:	6906                	ld	s2,64(sp)
    800034dc:	79e2                	ld	s3,56(sp)
    800034de:	7a42                	ld	s4,48(sp)
    800034e0:	7aa2                	ld	s5,40(sp)
    800034e2:	7b02                	ld	s6,32(sp)
    800034e4:	6be2                	ld	s7,24(sp)
    800034e6:	6c42                	ld	s8,16(sp)
    800034e8:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800034ea:	00005517          	auipc	a0,0x5
    800034ee:	09e50513          	add	a0,a0,158 # 80008588 <states.0+0x80>
    800034f2:	ffffd097          	auipc	ra,0xffffd
    800034f6:	0b8080e7          	jalr	184(ra) # 800005aa <printf>
  return 0;
    800034fa:	4481                	li	s1,0
    800034fc:	bfa9                	j	80003456 <balloc+0x9c>

00000000800034fe <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800034fe:	7179                	add	sp,sp,-48
    80003500:	f406                	sd	ra,40(sp)
    80003502:	f022                	sd	s0,32(sp)
    80003504:	ec26                	sd	s1,24(sp)
    80003506:	e84a                	sd	s2,16(sp)
    80003508:	e44e                	sd	s3,8(sp)
    8000350a:	1800                	add	s0,sp,48
    8000350c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000350e:	47ad                	li	a5,11
    80003510:	02b7e863          	bltu	a5,a1,80003540 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003514:	02059793          	sll	a5,a1,0x20
    80003518:	01e7d593          	srl	a1,a5,0x1e
    8000351c:	00b504b3          	add	s1,a0,a1
    80003520:	0504a903          	lw	s2,80(s1)
    80003524:	08091263          	bnez	s2,800035a8 <bmap+0xaa>
      addr = balloc(ip->dev);
    80003528:	4108                	lw	a0,0(a0)
    8000352a:	00000097          	auipc	ra,0x0
    8000352e:	e90080e7          	jalr	-368(ra) # 800033ba <balloc>
    80003532:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003536:	06090963          	beqz	s2,800035a8 <bmap+0xaa>
        return 0;
      ip->addrs[bn] = addr;
    8000353a:	0524a823          	sw	s2,80(s1)
    8000353e:	a0ad                	j	800035a8 <bmap+0xaa>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003540:	ff45849b          	addw	s1,a1,-12
    80003544:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003548:	0ff00793          	li	a5,255
    8000354c:	08e7e863          	bltu	a5,a4,800035dc <bmap+0xde>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003550:	08052903          	lw	s2,128(a0)
    80003554:	00091f63          	bnez	s2,80003572 <bmap+0x74>
      addr = balloc(ip->dev);
    80003558:	4108                	lw	a0,0(a0)
    8000355a:	00000097          	auipc	ra,0x0
    8000355e:	e60080e7          	jalr	-416(ra) # 800033ba <balloc>
    80003562:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003566:	04090163          	beqz	s2,800035a8 <bmap+0xaa>
    8000356a:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000356c:	0929a023          	sw	s2,128(s3)
    80003570:	a011                	j	80003574 <bmap+0x76>
    80003572:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003574:	85ca                	mv	a1,s2
    80003576:	0009a503          	lw	a0,0(s3)
    8000357a:	00000097          	auipc	ra,0x0
    8000357e:	b80080e7          	jalr	-1152(ra) # 800030fa <bread>
    80003582:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003584:	05850793          	add	a5,a0,88
    if((addr = a[bn]) == 0){
    80003588:	02049713          	sll	a4,s1,0x20
    8000358c:	01e75593          	srl	a1,a4,0x1e
    80003590:	00b784b3          	add	s1,a5,a1
    80003594:	0004a903          	lw	s2,0(s1)
    80003598:	02090063          	beqz	s2,800035b8 <bmap+0xba>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000359c:	8552                	mv	a0,s4
    8000359e:	00000097          	auipc	ra,0x0
    800035a2:	c8c080e7          	jalr	-884(ra) # 8000322a <brelse>
    return addr;
    800035a6:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800035a8:	854a                	mv	a0,s2
    800035aa:	70a2                	ld	ra,40(sp)
    800035ac:	7402                	ld	s0,32(sp)
    800035ae:	64e2                	ld	s1,24(sp)
    800035b0:	6942                	ld	s2,16(sp)
    800035b2:	69a2                	ld	s3,8(sp)
    800035b4:	6145                	add	sp,sp,48
    800035b6:	8082                	ret
      addr = balloc(ip->dev);
    800035b8:	0009a503          	lw	a0,0(s3)
    800035bc:	00000097          	auipc	ra,0x0
    800035c0:	dfe080e7          	jalr	-514(ra) # 800033ba <balloc>
    800035c4:	0005091b          	sext.w	s2,a0
      if(addr){
    800035c8:	fc090ae3          	beqz	s2,8000359c <bmap+0x9e>
        a[bn] = addr;
    800035cc:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800035d0:	8552                	mv	a0,s4
    800035d2:	00001097          	auipc	ra,0x1
    800035d6:	f02080e7          	jalr	-254(ra) # 800044d4 <log_write>
    800035da:	b7c9                	j	8000359c <bmap+0x9e>
    800035dc:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800035de:	00005517          	auipc	a0,0x5
    800035e2:	fc250513          	add	a0,a0,-62 # 800085a0 <states.0+0x98>
    800035e6:	ffffd097          	auipc	ra,0xffffd
    800035ea:	f7a080e7          	jalr	-134(ra) # 80000560 <panic>

00000000800035ee <iget>:
{
    800035ee:	7179                	add	sp,sp,-48
    800035f0:	f406                	sd	ra,40(sp)
    800035f2:	f022                	sd	s0,32(sp)
    800035f4:	ec26                	sd	s1,24(sp)
    800035f6:	e84a                	sd	s2,16(sp)
    800035f8:	e44e                	sd	s3,8(sp)
    800035fa:	e052                	sd	s4,0(sp)
    800035fc:	1800                	add	s0,sp,48
    800035fe:	89aa                	mv	s3,a0
    80003600:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003602:	0001f517          	auipc	a0,0x1f
    80003606:	a0650513          	add	a0,a0,-1530 # 80022008 <itable>
    8000360a:	ffffd097          	auipc	ra,0xffffd
    8000360e:	62e080e7          	jalr	1582(ra) # 80000c38 <acquire>
  empty = 0;
    80003612:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003614:	0001f497          	auipc	s1,0x1f
    80003618:	a0c48493          	add	s1,s1,-1524 # 80022020 <itable+0x18>
    8000361c:	00020697          	auipc	a3,0x20
    80003620:	49468693          	add	a3,a3,1172 # 80023ab0 <log>
    80003624:	a039                	j	80003632 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003626:	02090b63          	beqz	s2,8000365c <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000362a:	08848493          	add	s1,s1,136
    8000362e:	02d48a63          	beq	s1,a3,80003662 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003632:	449c                	lw	a5,8(s1)
    80003634:	fef059e3          	blez	a5,80003626 <iget+0x38>
    80003638:	4098                	lw	a4,0(s1)
    8000363a:	ff3716e3          	bne	a4,s3,80003626 <iget+0x38>
    8000363e:	40d8                	lw	a4,4(s1)
    80003640:	ff4713e3          	bne	a4,s4,80003626 <iget+0x38>
      ip->ref++;
    80003644:	2785                	addw	a5,a5,1
    80003646:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003648:	0001f517          	auipc	a0,0x1f
    8000364c:	9c050513          	add	a0,a0,-1600 # 80022008 <itable>
    80003650:	ffffd097          	auipc	ra,0xffffd
    80003654:	69c080e7          	jalr	1692(ra) # 80000cec <release>
      return ip;
    80003658:	8926                	mv	s2,s1
    8000365a:	a03d                	j	80003688 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000365c:	f7f9                	bnez	a5,8000362a <iget+0x3c>
      empty = ip;
    8000365e:	8926                	mv	s2,s1
    80003660:	b7e9                	j	8000362a <iget+0x3c>
  if(empty == 0)
    80003662:	02090c63          	beqz	s2,8000369a <iget+0xac>
  ip->dev = dev;
    80003666:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000366a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000366e:	4785                	li	a5,1
    80003670:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003674:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003678:	0001f517          	auipc	a0,0x1f
    8000367c:	99050513          	add	a0,a0,-1648 # 80022008 <itable>
    80003680:	ffffd097          	auipc	ra,0xffffd
    80003684:	66c080e7          	jalr	1644(ra) # 80000cec <release>
}
    80003688:	854a                	mv	a0,s2
    8000368a:	70a2                	ld	ra,40(sp)
    8000368c:	7402                	ld	s0,32(sp)
    8000368e:	64e2                	ld	s1,24(sp)
    80003690:	6942                	ld	s2,16(sp)
    80003692:	69a2                	ld	s3,8(sp)
    80003694:	6a02                	ld	s4,0(sp)
    80003696:	6145                	add	sp,sp,48
    80003698:	8082                	ret
    panic("iget: no inodes");
    8000369a:	00005517          	auipc	a0,0x5
    8000369e:	f1e50513          	add	a0,a0,-226 # 800085b8 <states.0+0xb0>
    800036a2:	ffffd097          	auipc	ra,0xffffd
    800036a6:	ebe080e7          	jalr	-322(ra) # 80000560 <panic>

00000000800036aa <fsinit>:
fsinit(int dev) {
    800036aa:	7179                	add	sp,sp,-48
    800036ac:	f406                	sd	ra,40(sp)
    800036ae:	f022                	sd	s0,32(sp)
    800036b0:	ec26                	sd	s1,24(sp)
    800036b2:	e84a                	sd	s2,16(sp)
    800036b4:	e44e                	sd	s3,8(sp)
    800036b6:	1800                	add	s0,sp,48
    800036b8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800036ba:	4585                	li	a1,1
    800036bc:	00000097          	auipc	ra,0x0
    800036c0:	a3e080e7          	jalr	-1474(ra) # 800030fa <bread>
    800036c4:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036c6:	0001f997          	auipc	s3,0x1f
    800036ca:	92298993          	add	s3,s3,-1758 # 80021fe8 <sb>
    800036ce:	02000613          	li	a2,32
    800036d2:	05850593          	add	a1,a0,88
    800036d6:	854e                	mv	a0,s3
    800036d8:	ffffd097          	auipc	ra,0xffffd
    800036dc:	6b8080e7          	jalr	1720(ra) # 80000d90 <memmove>
  brelse(bp);
    800036e0:	8526                	mv	a0,s1
    800036e2:	00000097          	auipc	ra,0x0
    800036e6:	b48080e7          	jalr	-1208(ra) # 8000322a <brelse>
  if(sb.magic != FSMAGIC)
    800036ea:	0009a703          	lw	a4,0(s3)
    800036ee:	102037b7          	lui	a5,0x10203
    800036f2:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036f6:	02f71263          	bne	a4,a5,8000371a <fsinit+0x70>
  initlog(dev, &sb);
    800036fa:	0001f597          	auipc	a1,0x1f
    800036fe:	8ee58593          	add	a1,a1,-1810 # 80021fe8 <sb>
    80003702:	854a                	mv	a0,s2
    80003704:	00001097          	auipc	ra,0x1
    80003708:	b60080e7          	jalr	-1184(ra) # 80004264 <initlog>
}
    8000370c:	70a2                	ld	ra,40(sp)
    8000370e:	7402                	ld	s0,32(sp)
    80003710:	64e2                	ld	s1,24(sp)
    80003712:	6942                	ld	s2,16(sp)
    80003714:	69a2                	ld	s3,8(sp)
    80003716:	6145                	add	sp,sp,48
    80003718:	8082                	ret
    panic("invalid file system");
    8000371a:	00005517          	auipc	a0,0x5
    8000371e:	eae50513          	add	a0,a0,-338 # 800085c8 <states.0+0xc0>
    80003722:	ffffd097          	auipc	ra,0xffffd
    80003726:	e3e080e7          	jalr	-450(ra) # 80000560 <panic>

000000008000372a <iinit>:
{
    8000372a:	7179                	add	sp,sp,-48
    8000372c:	f406                	sd	ra,40(sp)
    8000372e:	f022                	sd	s0,32(sp)
    80003730:	ec26                	sd	s1,24(sp)
    80003732:	e84a                	sd	s2,16(sp)
    80003734:	e44e                	sd	s3,8(sp)
    80003736:	1800                	add	s0,sp,48
  initlock(&itable.lock, "itable");
    80003738:	00005597          	auipc	a1,0x5
    8000373c:	ea858593          	add	a1,a1,-344 # 800085e0 <states.0+0xd8>
    80003740:	0001f517          	auipc	a0,0x1f
    80003744:	8c850513          	add	a0,a0,-1848 # 80022008 <itable>
    80003748:	ffffd097          	auipc	ra,0xffffd
    8000374c:	460080e7          	jalr	1120(ra) # 80000ba8 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003750:	0001f497          	auipc	s1,0x1f
    80003754:	8e048493          	add	s1,s1,-1824 # 80022030 <itable+0x28>
    80003758:	00020997          	auipc	s3,0x20
    8000375c:	36898993          	add	s3,s3,872 # 80023ac0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003760:	00005917          	auipc	s2,0x5
    80003764:	e8890913          	add	s2,s2,-376 # 800085e8 <states.0+0xe0>
    80003768:	85ca                	mv	a1,s2
    8000376a:	8526                	mv	a0,s1
    8000376c:	00001097          	auipc	ra,0x1
    80003770:	e4c080e7          	jalr	-436(ra) # 800045b8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003774:	08848493          	add	s1,s1,136
    80003778:	ff3498e3          	bne	s1,s3,80003768 <iinit+0x3e>
}
    8000377c:	70a2                	ld	ra,40(sp)
    8000377e:	7402                	ld	s0,32(sp)
    80003780:	64e2                	ld	s1,24(sp)
    80003782:	6942                	ld	s2,16(sp)
    80003784:	69a2                	ld	s3,8(sp)
    80003786:	6145                	add	sp,sp,48
    80003788:	8082                	ret

000000008000378a <ialloc>:
{
    8000378a:	7139                	add	sp,sp,-64
    8000378c:	fc06                	sd	ra,56(sp)
    8000378e:	f822                	sd	s0,48(sp)
    80003790:	0080                	add	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003792:	0001f717          	auipc	a4,0x1f
    80003796:	86272703          	lw	a4,-1950(a4) # 80021ff4 <sb+0xc>
    8000379a:	4785                	li	a5,1
    8000379c:	06e7f463          	bgeu	a5,a4,80003804 <ialloc+0x7a>
    800037a0:	f426                	sd	s1,40(sp)
    800037a2:	f04a                	sd	s2,32(sp)
    800037a4:	ec4e                	sd	s3,24(sp)
    800037a6:	e852                	sd	s4,16(sp)
    800037a8:	e456                	sd	s5,8(sp)
    800037aa:	e05a                	sd	s6,0(sp)
    800037ac:	8aaa                	mv	s5,a0
    800037ae:	8b2e                	mv	s6,a1
    800037b0:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800037b2:	0001fa17          	auipc	s4,0x1f
    800037b6:	836a0a13          	add	s4,s4,-1994 # 80021fe8 <sb>
    800037ba:	00495593          	srl	a1,s2,0x4
    800037be:	018a2783          	lw	a5,24(s4)
    800037c2:	9dbd                	addw	a1,a1,a5
    800037c4:	8556                	mv	a0,s5
    800037c6:	00000097          	auipc	ra,0x0
    800037ca:	934080e7          	jalr	-1740(ra) # 800030fa <bread>
    800037ce:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800037d0:	05850993          	add	s3,a0,88
    800037d4:	00f97793          	and	a5,s2,15
    800037d8:	079a                	sll	a5,a5,0x6
    800037da:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800037dc:	00099783          	lh	a5,0(s3)
    800037e0:	cf9d                	beqz	a5,8000381e <ialloc+0x94>
    brelse(bp);
    800037e2:	00000097          	auipc	ra,0x0
    800037e6:	a48080e7          	jalr	-1464(ra) # 8000322a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800037ea:	0905                	add	s2,s2,1
    800037ec:	00ca2703          	lw	a4,12(s4)
    800037f0:	0009079b          	sext.w	a5,s2
    800037f4:	fce7e3e3          	bltu	a5,a4,800037ba <ialloc+0x30>
    800037f8:	74a2                	ld	s1,40(sp)
    800037fa:	7902                	ld	s2,32(sp)
    800037fc:	69e2                	ld	s3,24(sp)
    800037fe:	6a42                	ld	s4,16(sp)
    80003800:	6aa2                	ld	s5,8(sp)
    80003802:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003804:	00005517          	auipc	a0,0x5
    80003808:	dec50513          	add	a0,a0,-532 # 800085f0 <states.0+0xe8>
    8000380c:	ffffd097          	auipc	ra,0xffffd
    80003810:	d9e080e7          	jalr	-610(ra) # 800005aa <printf>
  return 0;
    80003814:	4501                	li	a0,0
}
    80003816:	70e2                	ld	ra,56(sp)
    80003818:	7442                	ld	s0,48(sp)
    8000381a:	6121                	add	sp,sp,64
    8000381c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000381e:	04000613          	li	a2,64
    80003822:	4581                	li	a1,0
    80003824:	854e                	mv	a0,s3
    80003826:	ffffd097          	auipc	ra,0xffffd
    8000382a:	50e080e7          	jalr	1294(ra) # 80000d34 <memset>
      dip->type = type;
    8000382e:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003832:	8526                	mv	a0,s1
    80003834:	00001097          	auipc	ra,0x1
    80003838:	ca0080e7          	jalr	-864(ra) # 800044d4 <log_write>
      brelse(bp);
    8000383c:	8526                	mv	a0,s1
    8000383e:	00000097          	auipc	ra,0x0
    80003842:	9ec080e7          	jalr	-1556(ra) # 8000322a <brelse>
      return iget(dev, inum);
    80003846:	0009059b          	sext.w	a1,s2
    8000384a:	8556                	mv	a0,s5
    8000384c:	00000097          	auipc	ra,0x0
    80003850:	da2080e7          	jalr	-606(ra) # 800035ee <iget>
    80003854:	74a2                	ld	s1,40(sp)
    80003856:	7902                	ld	s2,32(sp)
    80003858:	69e2                	ld	s3,24(sp)
    8000385a:	6a42                	ld	s4,16(sp)
    8000385c:	6aa2                	ld	s5,8(sp)
    8000385e:	6b02                	ld	s6,0(sp)
    80003860:	bf5d                	j	80003816 <ialloc+0x8c>

0000000080003862 <iupdate>:
{
    80003862:	1101                	add	sp,sp,-32
    80003864:	ec06                	sd	ra,24(sp)
    80003866:	e822                	sd	s0,16(sp)
    80003868:	e426                	sd	s1,8(sp)
    8000386a:	e04a                	sd	s2,0(sp)
    8000386c:	1000                	add	s0,sp,32
    8000386e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003870:	415c                	lw	a5,4(a0)
    80003872:	0047d79b          	srlw	a5,a5,0x4
    80003876:	0001e597          	auipc	a1,0x1e
    8000387a:	78a5a583          	lw	a1,1930(a1) # 80022000 <sb+0x18>
    8000387e:	9dbd                	addw	a1,a1,a5
    80003880:	4108                	lw	a0,0(a0)
    80003882:	00000097          	auipc	ra,0x0
    80003886:	878080e7          	jalr	-1928(ra) # 800030fa <bread>
    8000388a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000388c:	05850793          	add	a5,a0,88
    80003890:	40d8                	lw	a4,4(s1)
    80003892:	8b3d                	and	a4,a4,15
    80003894:	071a                	sll	a4,a4,0x6
    80003896:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003898:	04449703          	lh	a4,68(s1)
    8000389c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800038a0:	04649703          	lh	a4,70(s1)
    800038a4:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800038a8:	04849703          	lh	a4,72(s1)
    800038ac:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800038b0:	04a49703          	lh	a4,74(s1)
    800038b4:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800038b8:	44f8                	lw	a4,76(s1)
    800038ba:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800038bc:	03400613          	li	a2,52
    800038c0:	05048593          	add	a1,s1,80
    800038c4:	00c78513          	add	a0,a5,12
    800038c8:	ffffd097          	auipc	ra,0xffffd
    800038cc:	4c8080e7          	jalr	1224(ra) # 80000d90 <memmove>
  log_write(bp);
    800038d0:	854a                	mv	a0,s2
    800038d2:	00001097          	auipc	ra,0x1
    800038d6:	c02080e7          	jalr	-1022(ra) # 800044d4 <log_write>
  brelse(bp);
    800038da:	854a                	mv	a0,s2
    800038dc:	00000097          	auipc	ra,0x0
    800038e0:	94e080e7          	jalr	-1714(ra) # 8000322a <brelse>
}
    800038e4:	60e2                	ld	ra,24(sp)
    800038e6:	6442                	ld	s0,16(sp)
    800038e8:	64a2                	ld	s1,8(sp)
    800038ea:	6902                	ld	s2,0(sp)
    800038ec:	6105                	add	sp,sp,32
    800038ee:	8082                	ret

00000000800038f0 <idup>:
{
    800038f0:	1101                	add	sp,sp,-32
    800038f2:	ec06                	sd	ra,24(sp)
    800038f4:	e822                	sd	s0,16(sp)
    800038f6:	e426                	sd	s1,8(sp)
    800038f8:	1000                	add	s0,sp,32
    800038fa:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038fc:	0001e517          	auipc	a0,0x1e
    80003900:	70c50513          	add	a0,a0,1804 # 80022008 <itable>
    80003904:	ffffd097          	auipc	ra,0xffffd
    80003908:	334080e7          	jalr	820(ra) # 80000c38 <acquire>
  ip->ref++;
    8000390c:	449c                	lw	a5,8(s1)
    8000390e:	2785                	addw	a5,a5,1
    80003910:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003912:	0001e517          	auipc	a0,0x1e
    80003916:	6f650513          	add	a0,a0,1782 # 80022008 <itable>
    8000391a:	ffffd097          	auipc	ra,0xffffd
    8000391e:	3d2080e7          	jalr	978(ra) # 80000cec <release>
}
    80003922:	8526                	mv	a0,s1
    80003924:	60e2                	ld	ra,24(sp)
    80003926:	6442                	ld	s0,16(sp)
    80003928:	64a2                	ld	s1,8(sp)
    8000392a:	6105                	add	sp,sp,32
    8000392c:	8082                	ret

000000008000392e <ilock>:
{
    8000392e:	1101                	add	sp,sp,-32
    80003930:	ec06                	sd	ra,24(sp)
    80003932:	e822                	sd	s0,16(sp)
    80003934:	e426                	sd	s1,8(sp)
    80003936:	1000                	add	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003938:	c10d                	beqz	a0,8000395a <ilock+0x2c>
    8000393a:	84aa                	mv	s1,a0
    8000393c:	451c                	lw	a5,8(a0)
    8000393e:	00f05e63          	blez	a5,8000395a <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003942:	0541                	add	a0,a0,16
    80003944:	00001097          	auipc	ra,0x1
    80003948:	cae080e7          	jalr	-850(ra) # 800045f2 <acquiresleep>
  if(ip->valid == 0){
    8000394c:	40bc                	lw	a5,64(s1)
    8000394e:	cf99                	beqz	a5,8000396c <ilock+0x3e>
}
    80003950:	60e2                	ld	ra,24(sp)
    80003952:	6442                	ld	s0,16(sp)
    80003954:	64a2                	ld	s1,8(sp)
    80003956:	6105                	add	sp,sp,32
    80003958:	8082                	ret
    8000395a:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000395c:	00005517          	auipc	a0,0x5
    80003960:	cac50513          	add	a0,a0,-852 # 80008608 <states.0+0x100>
    80003964:	ffffd097          	auipc	ra,0xffffd
    80003968:	bfc080e7          	jalr	-1028(ra) # 80000560 <panic>
    8000396c:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000396e:	40dc                	lw	a5,4(s1)
    80003970:	0047d79b          	srlw	a5,a5,0x4
    80003974:	0001e597          	auipc	a1,0x1e
    80003978:	68c5a583          	lw	a1,1676(a1) # 80022000 <sb+0x18>
    8000397c:	9dbd                	addw	a1,a1,a5
    8000397e:	4088                	lw	a0,0(s1)
    80003980:	fffff097          	auipc	ra,0xfffff
    80003984:	77a080e7          	jalr	1914(ra) # 800030fa <bread>
    80003988:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000398a:	05850593          	add	a1,a0,88
    8000398e:	40dc                	lw	a5,4(s1)
    80003990:	8bbd                	and	a5,a5,15
    80003992:	079a                	sll	a5,a5,0x6
    80003994:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003996:	00059783          	lh	a5,0(a1)
    8000399a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000399e:	00259783          	lh	a5,2(a1)
    800039a2:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800039a6:	00459783          	lh	a5,4(a1)
    800039aa:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800039ae:	00659783          	lh	a5,6(a1)
    800039b2:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800039b6:	459c                	lw	a5,8(a1)
    800039b8:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800039ba:	03400613          	li	a2,52
    800039be:	05b1                	add	a1,a1,12
    800039c0:	05048513          	add	a0,s1,80
    800039c4:	ffffd097          	auipc	ra,0xffffd
    800039c8:	3cc080e7          	jalr	972(ra) # 80000d90 <memmove>
    brelse(bp);
    800039cc:	854a                	mv	a0,s2
    800039ce:	00000097          	auipc	ra,0x0
    800039d2:	85c080e7          	jalr	-1956(ra) # 8000322a <brelse>
    ip->valid = 1;
    800039d6:	4785                	li	a5,1
    800039d8:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800039da:	04449783          	lh	a5,68(s1)
    800039de:	c399                	beqz	a5,800039e4 <ilock+0xb6>
    800039e0:	6902                	ld	s2,0(sp)
    800039e2:	b7bd                	j	80003950 <ilock+0x22>
      panic("ilock: no type");
    800039e4:	00005517          	auipc	a0,0x5
    800039e8:	c2c50513          	add	a0,a0,-980 # 80008610 <states.0+0x108>
    800039ec:	ffffd097          	auipc	ra,0xffffd
    800039f0:	b74080e7          	jalr	-1164(ra) # 80000560 <panic>

00000000800039f4 <iunlock>:
{
    800039f4:	1101                	add	sp,sp,-32
    800039f6:	ec06                	sd	ra,24(sp)
    800039f8:	e822                	sd	s0,16(sp)
    800039fa:	e426                	sd	s1,8(sp)
    800039fc:	e04a                	sd	s2,0(sp)
    800039fe:	1000                	add	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a00:	c905                	beqz	a0,80003a30 <iunlock+0x3c>
    80003a02:	84aa                	mv	s1,a0
    80003a04:	01050913          	add	s2,a0,16
    80003a08:	854a                	mv	a0,s2
    80003a0a:	00001097          	auipc	ra,0x1
    80003a0e:	c82080e7          	jalr	-894(ra) # 8000468c <holdingsleep>
    80003a12:	cd19                	beqz	a0,80003a30 <iunlock+0x3c>
    80003a14:	449c                	lw	a5,8(s1)
    80003a16:	00f05d63          	blez	a5,80003a30 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a1a:	854a                	mv	a0,s2
    80003a1c:	00001097          	auipc	ra,0x1
    80003a20:	c2c080e7          	jalr	-980(ra) # 80004648 <releasesleep>
}
    80003a24:	60e2                	ld	ra,24(sp)
    80003a26:	6442                	ld	s0,16(sp)
    80003a28:	64a2                	ld	s1,8(sp)
    80003a2a:	6902                	ld	s2,0(sp)
    80003a2c:	6105                	add	sp,sp,32
    80003a2e:	8082                	ret
    panic("iunlock");
    80003a30:	00005517          	auipc	a0,0x5
    80003a34:	bf050513          	add	a0,a0,-1040 # 80008620 <states.0+0x118>
    80003a38:	ffffd097          	auipc	ra,0xffffd
    80003a3c:	b28080e7          	jalr	-1240(ra) # 80000560 <panic>

0000000080003a40 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a40:	7179                	add	sp,sp,-48
    80003a42:	f406                	sd	ra,40(sp)
    80003a44:	f022                	sd	s0,32(sp)
    80003a46:	ec26                	sd	s1,24(sp)
    80003a48:	e84a                	sd	s2,16(sp)
    80003a4a:	e44e                	sd	s3,8(sp)
    80003a4c:	1800                	add	s0,sp,48
    80003a4e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a50:	05050493          	add	s1,a0,80
    80003a54:	08050913          	add	s2,a0,128
    80003a58:	a021                	j	80003a60 <itrunc+0x20>
    80003a5a:	0491                	add	s1,s1,4
    80003a5c:	01248d63          	beq	s1,s2,80003a76 <itrunc+0x36>
    if(ip->addrs[i]){
    80003a60:	408c                	lw	a1,0(s1)
    80003a62:	dde5                	beqz	a1,80003a5a <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003a64:	0009a503          	lw	a0,0(s3)
    80003a68:	00000097          	auipc	ra,0x0
    80003a6c:	8d6080e7          	jalr	-1834(ra) # 8000333e <bfree>
      ip->addrs[i] = 0;
    80003a70:	0004a023          	sw	zero,0(s1)
    80003a74:	b7dd                	j	80003a5a <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a76:	0809a583          	lw	a1,128(s3)
    80003a7a:	ed99                	bnez	a1,80003a98 <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a7c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a80:	854e                	mv	a0,s3
    80003a82:	00000097          	auipc	ra,0x0
    80003a86:	de0080e7          	jalr	-544(ra) # 80003862 <iupdate>
}
    80003a8a:	70a2                	ld	ra,40(sp)
    80003a8c:	7402                	ld	s0,32(sp)
    80003a8e:	64e2                	ld	s1,24(sp)
    80003a90:	6942                	ld	s2,16(sp)
    80003a92:	69a2                	ld	s3,8(sp)
    80003a94:	6145                	add	sp,sp,48
    80003a96:	8082                	ret
    80003a98:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a9a:	0009a503          	lw	a0,0(s3)
    80003a9e:	fffff097          	auipc	ra,0xfffff
    80003aa2:	65c080e7          	jalr	1628(ra) # 800030fa <bread>
    80003aa6:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003aa8:	05850493          	add	s1,a0,88
    80003aac:	45850913          	add	s2,a0,1112
    80003ab0:	a021                	j	80003ab8 <itrunc+0x78>
    80003ab2:	0491                	add	s1,s1,4
    80003ab4:	01248b63          	beq	s1,s2,80003aca <itrunc+0x8a>
      if(a[j])
    80003ab8:	408c                	lw	a1,0(s1)
    80003aba:	dde5                	beqz	a1,80003ab2 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003abc:	0009a503          	lw	a0,0(s3)
    80003ac0:	00000097          	auipc	ra,0x0
    80003ac4:	87e080e7          	jalr	-1922(ra) # 8000333e <bfree>
    80003ac8:	b7ed                	j	80003ab2 <itrunc+0x72>
    brelse(bp);
    80003aca:	8552                	mv	a0,s4
    80003acc:	fffff097          	auipc	ra,0xfffff
    80003ad0:	75e080e7          	jalr	1886(ra) # 8000322a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ad4:	0809a583          	lw	a1,128(s3)
    80003ad8:	0009a503          	lw	a0,0(s3)
    80003adc:	00000097          	auipc	ra,0x0
    80003ae0:	862080e7          	jalr	-1950(ra) # 8000333e <bfree>
    ip->addrs[NDIRECT] = 0;
    80003ae4:	0809a023          	sw	zero,128(s3)
    80003ae8:	6a02                	ld	s4,0(sp)
    80003aea:	bf49                	j	80003a7c <itrunc+0x3c>

0000000080003aec <iput>:
{
    80003aec:	1101                	add	sp,sp,-32
    80003aee:	ec06                	sd	ra,24(sp)
    80003af0:	e822                	sd	s0,16(sp)
    80003af2:	e426                	sd	s1,8(sp)
    80003af4:	1000                	add	s0,sp,32
    80003af6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003af8:	0001e517          	auipc	a0,0x1e
    80003afc:	51050513          	add	a0,a0,1296 # 80022008 <itable>
    80003b00:	ffffd097          	auipc	ra,0xffffd
    80003b04:	138080e7          	jalr	312(ra) # 80000c38 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b08:	4498                	lw	a4,8(s1)
    80003b0a:	4785                	li	a5,1
    80003b0c:	02f70263          	beq	a4,a5,80003b30 <iput+0x44>
  ip->ref--;
    80003b10:	449c                	lw	a5,8(s1)
    80003b12:	37fd                	addw	a5,a5,-1
    80003b14:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b16:	0001e517          	auipc	a0,0x1e
    80003b1a:	4f250513          	add	a0,a0,1266 # 80022008 <itable>
    80003b1e:	ffffd097          	auipc	ra,0xffffd
    80003b22:	1ce080e7          	jalr	462(ra) # 80000cec <release>
}
    80003b26:	60e2                	ld	ra,24(sp)
    80003b28:	6442                	ld	s0,16(sp)
    80003b2a:	64a2                	ld	s1,8(sp)
    80003b2c:	6105                	add	sp,sp,32
    80003b2e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b30:	40bc                	lw	a5,64(s1)
    80003b32:	dff9                	beqz	a5,80003b10 <iput+0x24>
    80003b34:	04a49783          	lh	a5,74(s1)
    80003b38:	ffe1                	bnez	a5,80003b10 <iput+0x24>
    80003b3a:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003b3c:	01048913          	add	s2,s1,16
    80003b40:	854a                	mv	a0,s2
    80003b42:	00001097          	auipc	ra,0x1
    80003b46:	ab0080e7          	jalr	-1360(ra) # 800045f2 <acquiresleep>
    release(&itable.lock);
    80003b4a:	0001e517          	auipc	a0,0x1e
    80003b4e:	4be50513          	add	a0,a0,1214 # 80022008 <itable>
    80003b52:	ffffd097          	auipc	ra,0xffffd
    80003b56:	19a080e7          	jalr	410(ra) # 80000cec <release>
    itrunc(ip);
    80003b5a:	8526                	mv	a0,s1
    80003b5c:	00000097          	auipc	ra,0x0
    80003b60:	ee4080e7          	jalr	-284(ra) # 80003a40 <itrunc>
    ip->type = 0;
    80003b64:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b68:	8526                	mv	a0,s1
    80003b6a:	00000097          	auipc	ra,0x0
    80003b6e:	cf8080e7          	jalr	-776(ra) # 80003862 <iupdate>
    ip->valid = 0;
    80003b72:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b76:	854a                	mv	a0,s2
    80003b78:	00001097          	auipc	ra,0x1
    80003b7c:	ad0080e7          	jalr	-1328(ra) # 80004648 <releasesleep>
    acquire(&itable.lock);
    80003b80:	0001e517          	auipc	a0,0x1e
    80003b84:	48850513          	add	a0,a0,1160 # 80022008 <itable>
    80003b88:	ffffd097          	auipc	ra,0xffffd
    80003b8c:	0b0080e7          	jalr	176(ra) # 80000c38 <acquire>
    80003b90:	6902                	ld	s2,0(sp)
    80003b92:	bfbd                	j	80003b10 <iput+0x24>

0000000080003b94 <iunlockput>:
{
    80003b94:	1101                	add	sp,sp,-32
    80003b96:	ec06                	sd	ra,24(sp)
    80003b98:	e822                	sd	s0,16(sp)
    80003b9a:	e426                	sd	s1,8(sp)
    80003b9c:	1000                	add	s0,sp,32
    80003b9e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ba0:	00000097          	auipc	ra,0x0
    80003ba4:	e54080e7          	jalr	-428(ra) # 800039f4 <iunlock>
  iput(ip);
    80003ba8:	8526                	mv	a0,s1
    80003baa:	00000097          	auipc	ra,0x0
    80003bae:	f42080e7          	jalr	-190(ra) # 80003aec <iput>
}
    80003bb2:	60e2                	ld	ra,24(sp)
    80003bb4:	6442                	ld	s0,16(sp)
    80003bb6:	64a2                	ld	s1,8(sp)
    80003bb8:	6105                	add	sp,sp,32
    80003bba:	8082                	ret

0000000080003bbc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003bbc:	1141                	add	sp,sp,-16
    80003bbe:	e422                	sd	s0,8(sp)
    80003bc0:	0800                	add	s0,sp,16
  st->dev = ip->dev;
    80003bc2:	411c                	lw	a5,0(a0)
    80003bc4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003bc6:	415c                	lw	a5,4(a0)
    80003bc8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003bca:	04451783          	lh	a5,68(a0)
    80003bce:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003bd2:	04a51783          	lh	a5,74(a0)
    80003bd6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003bda:	04c56783          	lwu	a5,76(a0)
    80003bde:	e99c                	sd	a5,16(a1)
}
    80003be0:	6422                	ld	s0,8(sp)
    80003be2:	0141                	add	sp,sp,16
    80003be4:	8082                	ret

0000000080003be6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003be6:	457c                	lw	a5,76(a0)
    80003be8:	10d7e563          	bltu	a5,a3,80003cf2 <readi+0x10c>
{
    80003bec:	7159                	add	sp,sp,-112
    80003bee:	f486                	sd	ra,104(sp)
    80003bf0:	f0a2                	sd	s0,96(sp)
    80003bf2:	eca6                	sd	s1,88(sp)
    80003bf4:	e0d2                	sd	s4,64(sp)
    80003bf6:	fc56                	sd	s5,56(sp)
    80003bf8:	f85a                	sd	s6,48(sp)
    80003bfa:	f45e                	sd	s7,40(sp)
    80003bfc:	1880                	add	s0,sp,112
    80003bfe:	8b2a                	mv	s6,a0
    80003c00:	8bae                	mv	s7,a1
    80003c02:	8a32                	mv	s4,a2
    80003c04:	84b6                	mv	s1,a3
    80003c06:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003c08:	9f35                	addw	a4,a4,a3
    return 0;
    80003c0a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c0c:	0cd76a63          	bltu	a4,a3,80003ce0 <readi+0xfa>
    80003c10:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003c12:	00e7f463          	bgeu	a5,a4,80003c1a <readi+0x34>
    n = ip->size - off;
    80003c16:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c1a:	0a0a8963          	beqz	s5,80003ccc <readi+0xe6>
    80003c1e:	e8ca                	sd	s2,80(sp)
    80003c20:	f062                	sd	s8,32(sp)
    80003c22:	ec66                	sd	s9,24(sp)
    80003c24:	e86a                	sd	s10,16(sp)
    80003c26:	e46e                	sd	s11,8(sp)
    80003c28:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c2a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c2e:	5c7d                	li	s8,-1
    80003c30:	a82d                	j	80003c6a <readi+0x84>
    80003c32:	020d1d93          	sll	s11,s10,0x20
    80003c36:	020ddd93          	srl	s11,s11,0x20
    80003c3a:	05890613          	add	a2,s2,88
    80003c3e:	86ee                	mv	a3,s11
    80003c40:	963a                	add	a2,a2,a4
    80003c42:	85d2                	mv	a1,s4
    80003c44:	855e                	mv	a0,s7
    80003c46:	fffff097          	auipc	ra,0xfffff
    80003c4a:	8c8080e7          	jalr	-1848(ra) # 8000250e <either_copyout>
    80003c4e:	05850d63          	beq	a0,s8,80003ca8 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c52:	854a                	mv	a0,s2
    80003c54:	fffff097          	auipc	ra,0xfffff
    80003c58:	5d6080e7          	jalr	1494(ra) # 8000322a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c5c:	013d09bb          	addw	s3,s10,s3
    80003c60:	009d04bb          	addw	s1,s10,s1
    80003c64:	9a6e                	add	s4,s4,s11
    80003c66:	0559fd63          	bgeu	s3,s5,80003cc0 <readi+0xda>
    uint addr = bmap(ip, off/BSIZE);
    80003c6a:	00a4d59b          	srlw	a1,s1,0xa
    80003c6e:	855a                	mv	a0,s6
    80003c70:	00000097          	auipc	ra,0x0
    80003c74:	88e080e7          	jalr	-1906(ra) # 800034fe <bmap>
    80003c78:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003c7c:	c9b1                	beqz	a1,80003cd0 <readi+0xea>
    bp = bread(ip->dev, addr);
    80003c7e:	000b2503          	lw	a0,0(s6)
    80003c82:	fffff097          	auipc	ra,0xfffff
    80003c86:	478080e7          	jalr	1144(ra) # 800030fa <bread>
    80003c8a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c8c:	3ff4f713          	and	a4,s1,1023
    80003c90:	40ec87bb          	subw	a5,s9,a4
    80003c94:	413a86bb          	subw	a3,s5,s3
    80003c98:	8d3e                	mv	s10,a5
    80003c9a:	2781                	sext.w	a5,a5
    80003c9c:	0006861b          	sext.w	a2,a3
    80003ca0:	f8f679e3          	bgeu	a2,a5,80003c32 <readi+0x4c>
    80003ca4:	8d36                	mv	s10,a3
    80003ca6:	b771                	j	80003c32 <readi+0x4c>
      brelse(bp);
    80003ca8:	854a                	mv	a0,s2
    80003caa:	fffff097          	auipc	ra,0xfffff
    80003cae:	580080e7          	jalr	1408(ra) # 8000322a <brelse>
      tot = -1;
    80003cb2:	59fd                	li	s3,-1
      break;
    80003cb4:	6946                	ld	s2,80(sp)
    80003cb6:	7c02                	ld	s8,32(sp)
    80003cb8:	6ce2                	ld	s9,24(sp)
    80003cba:	6d42                	ld	s10,16(sp)
    80003cbc:	6da2                	ld	s11,8(sp)
    80003cbe:	a831                	j	80003cda <readi+0xf4>
    80003cc0:	6946                	ld	s2,80(sp)
    80003cc2:	7c02                	ld	s8,32(sp)
    80003cc4:	6ce2                	ld	s9,24(sp)
    80003cc6:	6d42                	ld	s10,16(sp)
    80003cc8:	6da2                	ld	s11,8(sp)
    80003cca:	a801                	j	80003cda <readi+0xf4>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ccc:	89d6                	mv	s3,s5
    80003cce:	a031                	j	80003cda <readi+0xf4>
    80003cd0:	6946                	ld	s2,80(sp)
    80003cd2:	7c02                	ld	s8,32(sp)
    80003cd4:	6ce2                	ld	s9,24(sp)
    80003cd6:	6d42                	ld	s10,16(sp)
    80003cd8:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003cda:	0009851b          	sext.w	a0,s3
    80003cde:	69a6                	ld	s3,72(sp)
}
    80003ce0:	70a6                	ld	ra,104(sp)
    80003ce2:	7406                	ld	s0,96(sp)
    80003ce4:	64e6                	ld	s1,88(sp)
    80003ce6:	6a06                	ld	s4,64(sp)
    80003ce8:	7ae2                	ld	s5,56(sp)
    80003cea:	7b42                	ld	s6,48(sp)
    80003cec:	7ba2                	ld	s7,40(sp)
    80003cee:	6165                	add	sp,sp,112
    80003cf0:	8082                	ret
    return 0;
    80003cf2:	4501                	li	a0,0
}
    80003cf4:	8082                	ret

0000000080003cf6 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cf6:	457c                	lw	a5,76(a0)
    80003cf8:	10d7ee63          	bltu	a5,a3,80003e14 <writei+0x11e>
{
    80003cfc:	7159                	add	sp,sp,-112
    80003cfe:	f486                	sd	ra,104(sp)
    80003d00:	f0a2                	sd	s0,96(sp)
    80003d02:	e8ca                	sd	s2,80(sp)
    80003d04:	e0d2                	sd	s4,64(sp)
    80003d06:	fc56                	sd	s5,56(sp)
    80003d08:	f85a                	sd	s6,48(sp)
    80003d0a:	f45e                	sd	s7,40(sp)
    80003d0c:	1880                	add	s0,sp,112
    80003d0e:	8aaa                	mv	s5,a0
    80003d10:	8bae                	mv	s7,a1
    80003d12:	8a32                	mv	s4,a2
    80003d14:	8936                	mv	s2,a3
    80003d16:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d18:	00e687bb          	addw	a5,a3,a4
    80003d1c:	0ed7ee63          	bltu	a5,a3,80003e18 <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d20:	00043737          	lui	a4,0x43
    80003d24:	0ef76c63          	bltu	a4,a5,80003e1c <writei+0x126>
    80003d28:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d2a:	0c0b0d63          	beqz	s6,80003e04 <writei+0x10e>
    80003d2e:	eca6                	sd	s1,88(sp)
    80003d30:	f062                	sd	s8,32(sp)
    80003d32:	ec66                	sd	s9,24(sp)
    80003d34:	e86a                	sd	s10,16(sp)
    80003d36:	e46e                	sd	s11,8(sp)
    80003d38:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d3a:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d3e:	5c7d                	li	s8,-1
    80003d40:	a091                	j	80003d84 <writei+0x8e>
    80003d42:	020d1d93          	sll	s11,s10,0x20
    80003d46:	020ddd93          	srl	s11,s11,0x20
    80003d4a:	05848513          	add	a0,s1,88
    80003d4e:	86ee                	mv	a3,s11
    80003d50:	8652                	mv	a2,s4
    80003d52:	85de                	mv	a1,s7
    80003d54:	953a                	add	a0,a0,a4
    80003d56:	fffff097          	auipc	ra,0xfffff
    80003d5a:	80e080e7          	jalr	-2034(ra) # 80002564 <either_copyin>
    80003d5e:	07850263          	beq	a0,s8,80003dc2 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d62:	8526                	mv	a0,s1
    80003d64:	00000097          	auipc	ra,0x0
    80003d68:	770080e7          	jalr	1904(ra) # 800044d4 <log_write>
    brelse(bp);
    80003d6c:	8526                	mv	a0,s1
    80003d6e:	fffff097          	auipc	ra,0xfffff
    80003d72:	4bc080e7          	jalr	1212(ra) # 8000322a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d76:	013d09bb          	addw	s3,s10,s3
    80003d7a:	012d093b          	addw	s2,s10,s2
    80003d7e:	9a6e                	add	s4,s4,s11
    80003d80:	0569f663          	bgeu	s3,s6,80003dcc <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003d84:	00a9559b          	srlw	a1,s2,0xa
    80003d88:	8556                	mv	a0,s5
    80003d8a:	fffff097          	auipc	ra,0xfffff
    80003d8e:	774080e7          	jalr	1908(ra) # 800034fe <bmap>
    80003d92:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d96:	c99d                	beqz	a1,80003dcc <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003d98:	000aa503          	lw	a0,0(s5)
    80003d9c:	fffff097          	auipc	ra,0xfffff
    80003da0:	35e080e7          	jalr	862(ra) # 800030fa <bread>
    80003da4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003da6:	3ff97713          	and	a4,s2,1023
    80003daa:	40ec87bb          	subw	a5,s9,a4
    80003dae:	413b06bb          	subw	a3,s6,s3
    80003db2:	8d3e                	mv	s10,a5
    80003db4:	2781                	sext.w	a5,a5
    80003db6:	0006861b          	sext.w	a2,a3
    80003dba:	f8f674e3          	bgeu	a2,a5,80003d42 <writei+0x4c>
    80003dbe:	8d36                	mv	s10,a3
    80003dc0:	b749                	j	80003d42 <writei+0x4c>
      brelse(bp);
    80003dc2:	8526                	mv	a0,s1
    80003dc4:	fffff097          	auipc	ra,0xfffff
    80003dc8:	466080e7          	jalr	1126(ra) # 8000322a <brelse>
  }

  if(off > ip->size)
    80003dcc:	04caa783          	lw	a5,76(s5)
    80003dd0:	0327fc63          	bgeu	a5,s2,80003e08 <writei+0x112>
    ip->size = off;
    80003dd4:	052aa623          	sw	s2,76(s5)
    80003dd8:	64e6                	ld	s1,88(sp)
    80003dda:	7c02                	ld	s8,32(sp)
    80003ddc:	6ce2                	ld	s9,24(sp)
    80003dde:	6d42                	ld	s10,16(sp)
    80003de0:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003de2:	8556                	mv	a0,s5
    80003de4:	00000097          	auipc	ra,0x0
    80003de8:	a7e080e7          	jalr	-1410(ra) # 80003862 <iupdate>

  return tot;
    80003dec:	0009851b          	sext.w	a0,s3
    80003df0:	69a6                	ld	s3,72(sp)
}
    80003df2:	70a6                	ld	ra,104(sp)
    80003df4:	7406                	ld	s0,96(sp)
    80003df6:	6946                	ld	s2,80(sp)
    80003df8:	6a06                	ld	s4,64(sp)
    80003dfa:	7ae2                	ld	s5,56(sp)
    80003dfc:	7b42                	ld	s6,48(sp)
    80003dfe:	7ba2                	ld	s7,40(sp)
    80003e00:	6165                	add	sp,sp,112
    80003e02:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e04:	89da                	mv	s3,s6
    80003e06:	bff1                	j	80003de2 <writei+0xec>
    80003e08:	64e6                	ld	s1,88(sp)
    80003e0a:	7c02                	ld	s8,32(sp)
    80003e0c:	6ce2                	ld	s9,24(sp)
    80003e0e:	6d42                	ld	s10,16(sp)
    80003e10:	6da2                	ld	s11,8(sp)
    80003e12:	bfc1                	j	80003de2 <writei+0xec>
    return -1;
    80003e14:	557d                	li	a0,-1
}
    80003e16:	8082                	ret
    return -1;
    80003e18:	557d                	li	a0,-1
    80003e1a:	bfe1                	j	80003df2 <writei+0xfc>
    return -1;
    80003e1c:	557d                	li	a0,-1
    80003e1e:	bfd1                	j	80003df2 <writei+0xfc>

0000000080003e20 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e20:	1141                	add	sp,sp,-16
    80003e22:	e406                	sd	ra,8(sp)
    80003e24:	e022                	sd	s0,0(sp)
    80003e26:	0800                	add	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e28:	4639                	li	a2,14
    80003e2a:	ffffd097          	auipc	ra,0xffffd
    80003e2e:	fda080e7          	jalr	-38(ra) # 80000e04 <strncmp>
}
    80003e32:	60a2                	ld	ra,8(sp)
    80003e34:	6402                	ld	s0,0(sp)
    80003e36:	0141                	add	sp,sp,16
    80003e38:	8082                	ret

0000000080003e3a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e3a:	7139                	add	sp,sp,-64
    80003e3c:	fc06                	sd	ra,56(sp)
    80003e3e:	f822                	sd	s0,48(sp)
    80003e40:	f426                	sd	s1,40(sp)
    80003e42:	f04a                	sd	s2,32(sp)
    80003e44:	ec4e                	sd	s3,24(sp)
    80003e46:	e852                	sd	s4,16(sp)
    80003e48:	0080                	add	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e4a:	04451703          	lh	a4,68(a0)
    80003e4e:	4785                	li	a5,1
    80003e50:	00f71a63          	bne	a4,a5,80003e64 <dirlookup+0x2a>
    80003e54:	892a                	mv	s2,a0
    80003e56:	89ae                	mv	s3,a1
    80003e58:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e5a:	457c                	lw	a5,76(a0)
    80003e5c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e5e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e60:	e79d                	bnez	a5,80003e8e <dirlookup+0x54>
    80003e62:	a8a5                	j	80003eda <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e64:	00004517          	auipc	a0,0x4
    80003e68:	7c450513          	add	a0,a0,1988 # 80008628 <states.0+0x120>
    80003e6c:	ffffc097          	auipc	ra,0xffffc
    80003e70:	6f4080e7          	jalr	1780(ra) # 80000560 <panic>
      panic("dirlookup read");
    80003e74:	00004517          	auipc	a0,0x4
    80003e78:	7cc50513          	add	a0,a0,1996 # 80008640 <states.0+0x138>
    80003e7c:	ffffc097          	auipc	ra,0xffffc
    80003e80:	6e4080e7          	jalr	1764(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e84:	24c1                	addw	s1,s1,16
    80003e86:	04c92783          	lw	a5,76(s2)
    80003e8a:	04f4f763          	bgeu	s1,a5,80003ed8 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e8e:	4741                	li	a4,16
    80003e90:	86a6                	mv	a3,s1
    80003e92:	fc040613          	add	a2,s0,-64
    80003e96:	4581                	li	a1,0
    80003e98:	854a                	mv	a0,s2
    80003e9a:	00000097          	auipc	ra,0x0
    80003e9e:	d4c080e7          	jalr	-692(ra) # 80003be6 <readi>
    80003ea2:	47c1                	li	a5,16
    80003ea4:	fcf518e3          	bne	a0,a5,80003e74 <dirlookup+0x3a>
    if(de.inum == 0)
    80003ea8:	fc045783          	lhu	a5,-64(s0)
    80003eac:	dfe1                	beqz	a5,80003e84 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003eae:	fc240593          	add	a1,s0,-62
    80003eb2:	854e                	mv	a0,s3
    80003eb4:	00000097          	auipc	ra,0x0
    80003eb8:	f6c080e7          	jalr	-148(ra) # 80003e20 <namecmp>
    80003ebc:	f561                	bnez	a0,80003e84 <dirlookup+0x4a>
      if(poff)
    80003ebe:	000a0463          	beqz	s4,80003ec6 <dirlookup+0x8c>
        *poff = off;
    80003ec2:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003ec6:	fc045583          	lhu	a1,-64(s0)
    80003eca:	00092503          	lw	a0,0(s2)
    80003ece:	fffff097          	auipc	ra,0xfffff
    80003ed2:	720080e7          	jalr	1824(ra) # 800035ee <iget>
    80003ed6:	a011                	j	80003eda <dirlookup+0xa0>
  return 0;
    80003ed8:	4501                	li	a0,0
}
    80003eda:	70e2                	ld	ra,56(sp)
    80003edc:	7442                	ld	s0,48(sp)
    80003ede:	74a2                	ld	s1,40(sp)
    80003ee0:	7902                	ld	s2,32(sp)
    80003ee2:	69e2                	ld	s3,24(sp)
    80003ee4:	6a42                	ld	s4,16(sp)
    80003ee6:	6121                	add	sp,sp,64
    80003ee8:	8082                	ret

0000000080003eea <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003eea:	711d                	add	sp,sp,-96
    80003eec:	ec86                	sd	ra,88(sp)
    80003eee:	e8a2                	sd	s0,80(sp)
    80003ef0:	e4a6                	sd	s1,72(sp)
    80003ef2:	e0ca                	sd	s2,64(sp)
    80003ef4:	fc4e                	sd	s3,56(sp)
    80003ef6:	f852                	sd	s4,48(sp)
    80003ef8:	f456                	sd	s5,40(sp)
    80003efa:	f05a                	sd	s6,32(sp)
    80003efc:	ec5e                	sd	s7,24(sp)
    80003efe:	e862                	sd	s8,16(sp)
    80003f00:	e466                	sd	s9,8(sp)
    80003f02:	1080                	add	s0,sp,96
    80003f04:	84aa                	mv	s1,a0
    80003f06:	8b2e                	mv	s6,a1
    80003f08:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f0a:	00054703          	lbu	a4,0(a0)
    80003f0e:	02f00793          	li	a5,47
    80003f12:	02f70263          	beq	a4,a5,80003f36 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f16:	ffffe097          	auipc	ra,0xffffe
    80003f1a:	b34080e7          	jalr	-1228(ra) # 80001a4a <myproc>
    80003f1e:	16853503          	ld	a0,360(a0)
    80003f22:	00000097          	auipc	ra,0x0
    80003f26:	9ce080e7          	jalr	-1586(ra) # 800038f0 <idup>
    80003f2a:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003f2c:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003f30:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f32:	4b85                	li	s7,1
    80003f34:	a875                	j	80003ff0 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003f36:	4585                	li	a1,1
    80003f38:	4505                	li	a0,1
    80003f3a:	fffff097          	auipc	ra,0xfffff
    80003f3e:	6b4080e7          	jalr	1716(ra) # 800035ee <iget>
    80003f42:	8a2a                	mv	s4,a0
    80003f44:	b7e5                	j	80003f2c <namex+0x42>
      iunlockput(ip);
    80003f46:	8552                	mv	a0,s4
    80003f48:	00000097          	auipc	ra,0x0
    80003f4c:	c4c080e7          	jalr	-948(ra) # 80003b94 <iunlockput>
      return 0;
    80003f50:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f52:	8552                	mv	a0,s4
    80003f54:	60e6                	ld	ra,88(sp)
    80003f56:	6446                	ld	s0,80(sp)
    80003f58:	64a6                	ld	s1,72(sp)
    80003f5a:	6906                	ld	s2,64(sp)
    80003f5c:	79e2                	ld	s3,56(sp)
    80003f5e:	7a42                	ld	s4,48(sp)
    80003f60:	7aa2                	ld	s5,40(sp)
    80003f62:	7b02                	ld	s6,32(sp)
    80003f64:	6be2                	ld	s7,24(sp)
    80003f66:	6c42                	ld	s8,16(sp)
    80003f68:	6ca2                	ld	s9,8(sp)
    80003f6a:	6125                	add	sp,sp,96
    80003f6c:	8082                	ret
      iunlock(ip);
    80003f6e:	8552                	mv	a0,s4
    80003f70:	00000097          	auipc	ra,0x0
    80003f74:	a84080e7          	jalr	-1404(ra) # 800039f4 <iunlock>
      return ip;
    80003f78:	bfe9                	j	80003f52 <namex+0x68>
      iunlockput(ip);
    80003f7a:	8552                	mv	a0,s4
    80003f7c:	00000097          	auipc	ra,0x0
    80003f80:	c18080e7          	jalr	-1000(ra) # 80003b94 <iunlockput>
      return 0;
    80003f84:	8a4e                	mv	s4,s3
    80003f86:	b7f1                	j	80003f52 <namex+0x68>
  len = path - s;
    80003f88:	40998633          	sub	a2,s3,s1
    80003f8c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003f90:	099c5863          	bge	s8,s9,80004020 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003f94:	4639                	li	a2,14
    80003f96:	85a6                	mv	a1,s1
    80003f98:	8556                	mv	a0,s5
    80003f9a:	ffffd097          	auipc	ra,0xffffd
    80003f9e:	df6080e7          	jalr	-522(ra) # 80000d90 <memmove>
    80003fa2:	84ce                	mv	s1,s3
  while(*path == '/')
    80003fa4:	0004c783          	lbu	a5,0(s1)
    80003fa8:	01279763          	bne	a5,s2,80003fb6 <namex+0xcc>
    path++;
    80003fac:	0485                	add	s1,s1,1
  while(*path == '/')
    80003fae:	0004c783          	lbu	a5,0(s1)
    80003fb2:	ff278de3          	beq	a5,s2,80003fac <namex+0xc2>
    ilock(ip);
    80003fb6:	8552                	mv	a0,s4
    80003fb8:	00000097          	auipc	ra,0x0
    80003fbc:	976080e7          	jalr	-1674(ra) # 8000392e <ilock>
    if(ip->type != T_DIR){
    80003fc0:	044a1783          	lh	a5,68(s4)
    80003fc4:	f97791e3          	bne	a5,s7,80003f46 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003fc8:	000b0563          	beqz	s6,80003fd2 <namex+0xe8>
    80003fcc:	0004c783          	lbu	a5,0(s1)
    80003fd0:	dfd9                	beqz	a5,80003f6e <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003fd2:	4601                	li	a2,0
    80003fd4:	85d6                	mv	a1,s5
    80003fd6:	8552                	mv	a0,s4
    80003fd8:	00000097          	auipc	ra,0x0
    80003fdc:	e62080e7          	jalr	-414(ra) # 80003e3a <dirlookup>
    80003fe0:	89aa                	mv	s3,a0
    80003fe2:	dd41                	beqz	a0,80003f7a <namex+0x90>
    iunlockput(ip);
    80003fe4:	8552                	mv	a0,s4
    80003fe6:	00000097          	auipc	ra,0x0
    80003fea:	bae080e7          	jalr	-1106(ra) # 80003b94 <iunlockput>
    ip = next;
    80003fee:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003ff0:	0004c783          	lbu	a5,0(s1)
    80003ff4:	01279763          	bne	a5,s2,80004002 <namex+0x118>
    path++;
    80003ff8:	0485                	add	s1,s1,1
  while(*path == '/')
    80003ffa:	0004c783          	lbu	a5,0(s1)
    80003ffe:	ff278de3          	beq	a5,s2,80003ff8 <namex+0x10e>
  if(*path == 0)
    80004002:	cb9d                	beqz	a5,80004038 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80004004:	0004c783          	lbu	a5,0(s1)
    80004008:	89a6                	mv	s3,s1
  len = path - s;
    8000400a:	4c81                	li	s9,0
    8000400c:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    8000400e:	01278963          	beq	a5,s2,80004020 <namex+0x136>
    80004012:	dbbd                	beqz	a5,80003f88 <namex+0x9e>
    path++;
    80004014:	0985                	add	s3,s3,1
  while(*path != '/' && *path != 0)
    80004016:	0009c783          	lbu	a5,0(s3)
    8000401a:	ff279ce3          	bne	a5,s2,80004012 <namex+0x128>
    8000401e:	b7ad                	j	80003f88 <namex+0x9e>
    memmove(name, s, len);
    80004020:	2601                	sext.w	a2,a2
    80004022:	85a6                	mv	a1,s1
    80004024:	8556                	mv	a0,s5
    80004026:	ffffd097          	auipc	ra,0xffffd
    8000402a:	d6a080e7          	jalr	-662(ra) # 80000d90 <memmove>
    name[len] = 0;
    8000402e:	9cd6                	add	s9,s9,s5
    80004030:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004034:	84ce                	mv	s1,s3
    80004036:	b7bd                	j	80003fa4 <namex+0xba>
  if(nameiparent){
    80004038:	f00b0de3          	beqz	s6,80003f52 <namex+0x68>
    iput(ip);
    8000403c:	8552                	mv	a0,s4
    8000403e:	00000097          	auipc	ra,0x0
    80004042:	aae080e7          	jalr	-1362(ra) # 80003aec <iput>
    return 0;
    80004046:	4a01                	li	s4,0
    80004048:	b729                	j	80003f52 <namex+0x68>

000000008000404a <dirlink>:
{
    8000404a:	7139                	add	sp,sp,-64
    8000404c:	fc06                	sd	ra,56(sp)
    8000404e:	f822                	sd	s0,48(sp)
    80004050:	f04a                	sd	s2,32(sp)
    80004052:	ec4e                	sd	s3,24(sp)
    80004054:	e852                	sd	s4,16(sp)
    80004056:	0080                	add	s0,sp,64
    80004058:	892a                	mv	s2,a0
    8000405a:	8a2e                	mv	s4,a1
    8000405c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000405e:	4601                	li	a2,0
    80004060:	00000097          	auipc	ra,0x0
    80004064:	dda080e7          	jalr	-550(ra) # 80003e3a <dirlookup>
    80004068:	ed25                	bnez	a0,800040e0 <dirlink+0x96>
    8000406a:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000406c:	04c92483          	lw	s1,76(s2)
    80004070:	c49d                	beqz	s1,8000409e <dirlink+0x54>
    80004072:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004074:	4741                	li	a4,16
    80004076:	86a6                	mv	a3,s1
    80004078:	fc040613          	add	a2,s0,-64
    8000407c:	4581                	li	a1,0
    8000407e:	854a                	mv	a0,s2
    80004080:	00000097          	auipc	ra,0x0
    80004084:	b66080e7          	jalr	-1178(ra) # 80003be6 <readi>
    80004088:	47c1                	li	a5,16
    8000408a:	06f51163          	bne	a0,a5,800040ec <dirlink+0xa2>
    if(de.inum == 0)
    8000408e:	fc045783          	lhu	a5,-64(s0)
    80004092:	c791                	beqz	a5,8000409e <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004094:	24c1                	addw	s1,s1,16
    80004096:	04c92783          	lw	a5,76(s2)
    8000409a:	fcf4ede3          	bltu	s1,a5,80004074 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000409e:	4639                	li	a2,14
    800040a0:	85d2                	mv	a1,s4
    800040a2:	fc240513          	add	a0,s0,-62
    800040a6:	ffffd097          	auipc	ra,0xffffd
    800040aa:	d94080e7          	jalr	-620(ra) # 80000e3a <strncpy>
  de.inum = inum;
    800040ae:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040b2:	4741                	li	a4,16
    800040b4:	86a6                	mv	a3,s1
    800040b6:	fc040613          	add	a2,s0,-64
    800040ba:	4581                	li	a1,0
    800040bc:	854a                	mv	a0,s2
    800040be:	00000097          	auipc	ra,0x0
    800040c2:	c38080e7          	jalr	-968(ra) # 80003cf6 <writei>
    800040c6:	1541                	add	a0,a0,-16
    800040c8:	00a03533          	snez	a0,a0
    800040cc:	40a00533          	neg	a0,a0
    800040d0:	74a2                	ld	s1,40(sp)
}
    800040d2:	70e2                	ld	ra,56(sp)
    800040d4:	7442                	ld	s0,48(sp)
    800040d6:	7902                	ld	s2,32(sp)
    800040d8:	69e2                	ld	s3,24(sp)
    800040da:	6a42                	ld	s4,16(sp)
    800040dc:	6121                	add	sp,sp,64
    800040de:	8082                	ret
    iput(ip);
    800040e0:	00000097          	auipc	ra,0x0
    800040e4:	a0c080e7          	jalr	-1524(ra) # 80003aec <iput>
    return -1;
    800040e8:	557d                	li	a0,-1
    800040ea:	b7e5                	j	800040d2 <dirlink+0x88>
      panic("dirlink read");
    800040ec:	00004517          	auipc	a0,0x4
    800040f0:	56450513          	add	a0,a0,1380 # 80008650 <states.0+0x148>
    800040f4:	ffffc097          	auipc	ra,0xffffc
    800040f8:	46c080e7          	jalr	1132(ra) # 80000560 <panic>

00000000800040fc <namei>:

struct inode*
namei(char *path)
{
    800040fc:	1101                	add	sp,sp,-32
    800040fe:	ec06                	sd	ra,24(sp)
    80004100:	e822                	sd	s0,16(sp)
    80004102:	1000                	add	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004104:	fe040613          	add	a2,s0,-32
    80004108:	4581                	li	a1,0
    8000410a:	00000097          	auipc	ra,0x0
    8000410e:	de0080e7          	jalr	-544(ra) # 80003eea <namex>
}
    80004112:	60e2                	ld	ra,24(sp)
    80004114:	6442                	ld	s0,16(sp)
    80004116:	6105                	add	sp,sp,32
    80004118:	8082                	ret

000000008000411a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000411a:	1141                	add	sp,sp,-16
    8000411c:	e406                	sd	ra,8(sp)
    8000411e:	e022                	sd	s0,0(sp)
    80004120:	0800                	add	s0,sp,16
    80004122:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004124:	4585                	li	a1,1
    80004126:	00000097          	auipc	ra,0x0
    8000412a:	dc4080e7          	jalr	-572(ra) # 80003eea <namex>
}
    8000412e:	60a2                	ld	ra,8(sp)
    80004130:	6402                	ld	s0,0(sp)
    80004132:	0141                	add	sp,sp,16
    80004134:	8082                	ret

0000000080004136 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004136:	1101                	add	sp,sp,-32
    80004138:	ec06                	sd	ra,24(sp)
    8000413a:	e822                	sd	s0,16(sp)
    8000413c:	e426                	sd	s1,8(sp)
    8000413e:	e04a                	sd	s2,0(sp)
    80004140:	1000                	add	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004142:	00020917          	auipc	s2,0x20
    80004146:	96e90913          	add	s2,s2,-1682 # 80023ab0 <log>
    8000414a:	01892583          	lw	a1,24(s2)
    8000414e:	02892503          	lw	a0,40(s2)
    80004152:	fffff097          	auipc	ra,0xfffff
    80004156:	fa8080e7          	jalr	-88(ra) # 800030fa <bread>
    8000415a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000415c:	02c92603          	lw	a2,44(s2)
    80004160:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004162:	00c05f63          	blez	a2,80004180 <write_head+0x4a>
    80004166:	00020717          	auipc	a4,0x20
    8000416a:	97a70713          	add	a4,a4,-1670 # 80023ae0 <log+0x30>
    8000416e:	87aa                	mv	a5,a0
    80004170:	060a                	sll	a2,a2,0x2
    80004172:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004174:	4314                	lw	a3,0(a4)
    80004176:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80004178:	0711                	add	a4,a4,4
    8000417a:	0791                	add	a5,a5,4
    8000417c:	fec79ce3          	bne	a5,a2,80004174 <write_head+0x3e>
  }
  bwrite(buf);
    80004180:	8526                	mv	a0,s1
    80004182:	fffff097          	auipc	ra,0xfffff
    80004186:	06a080e7          	jalr	106(ra) # 800031ec <bwrite>
  brelse(buf);
    8000418a:	8526                	mv	a0,s1
    8000418c:	fffff097          	auipc	ra,0xfffff
    80004190:	09e080e7          	jalr	158(ra) # 8000322a <brelse>
}
    80004194:	60e2                	ld	ra,24(sp)
    80004196:	6442                	ld	s0,16(sp)
    80004198:	64a2                	ld	s1,8(sp)
    8000419a:	6902                	ld	s2,0(sp)
    8000419c:	6105                	add	sp,sp,32
    8000419e:	8082                	ret

00000000800041a0 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800041a0:	00020797          	auipc	a5,0x20
    800041a4:	93c7a783          	lw	a5,-1732(a5) # 80023adc <log+0x2c>
    800041a8:	0af05d63          	blez	a5,80004262 <install_trans+0xc2>
{
    800041ac:	7139                	add	sp,sp,-64
    800041ae:	fc06                	sd	ra,56(sp)
    800041b0:	f822                	sd	s0,48(sp)
    800041b2:	f426                	sd	s1,40(sp)
    800041b4:	f04a                	sd	s2,32(sp)
    800041b6:	ec4e                	sd	s3,24(sp)
    800041b8:	e852                	sd	s4,16(sp)
    800041ba:	e456                	sd	s5,8(sp)
    800041bc:	e05a                	sd	s6,0(sp)
    800041be:	0080                	add	s0,sp,64
    800041c0:	8b2a                	mv	s6,a0
    800041c2:	00020a97          	auipc	s5,0x20
    800041c6:	91ea8a93          	add	s5,s5,-1762 # 80023ae0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041ca:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041cc:	00020997          	auipc	s3,0x20
    800041d0:	8e498993          	add	s3,s3,-1820 # 80023ab0 <log>
    800041d4:	a00d                	j	800041f6 <install_trans+0x56>
    brelse(lbuf);
    800041d6:	854a                	mv	a0,s2
    800041d8:	fffff097          	auipc	ra,0xfffff
    800041dc:	052080e7          	jalr	82(ra) # 8000322a <brelse>
    brelse(dbuf);
    800041e0:	8526                	mv	a0,s1
    800041e2:	fffff097          	auipc	ra,0xfffff
    800041e6:	048080e7          	jalr	72(ra) # 8000322a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041ea:	2a05                	addw	s4,s4,1
    800041ec:	0a91                	add	s5,s5,4
    800041ee:	02c9a783          	lw	a5,44(s3)
    800041f2:	04fa5e63          	bge	s4,a5,8000424e <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041f6:	0189a583          	lw	a1,24(s3)
    800041fa:	014585bb          	addw	a1,a1,s4
    800041fe:	2585                	addw	a1,a1,1
    80004200:	0289a503          	lw	a0,40(s3)
    80004204:	fffff097          	auipc	ra,0xfffff
    80004208:	ef6080e7          	jalr	-266(ra) # 800030fa <bread>
    8000420c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000420e:	000aa583          	lw	a1,0(s5)
    80004212:	0289a503          	lw	a0,40(s3)
    80004216:	fffff097          	auipc	ra,0xfffff
    8000421a:	ee4080e7          	jalr	-284(ra) # 800030fa <bread>
    8000421e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004220:	40000613          	li	a2,1024
    80004224:	05890593          	add	a1,s2,88
    80004228:	05850513          	add	a0,a0,88
    8000422c:	ffffd097          	auipc	ra,0xffffd
    80004230:	b64080e7          	jalr	-1180(ra) # 80000d90 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004234:	8526                	mv	a0,s1
    80004236:	fffff097          	auipc	ra,0xfffff
    8000423a:	fb6080e7          	jalr	-74(ra) # 800031ec <bwrite>
    if(recovering == 0)
    8000423e:	f80b1ce3          	bnez	s6,800041d6 <install_trans+0x36>
      bunpin(dbuf);
    80004242:	8526                	mv	a0,s1
    80004244:	fffff097          	auipc	ra,0xfffff
    80004248:	0be080e7          	jalr	190(ra) # 80003302 <bunpin>
    8000424c:	b769                	j	800041d6 <install_trans+0x36>
}
    8000424e:	70e2                	ld	ra,56(sp)
    80004250:	7442                	ld	s0,48(sp)
    80004252:	74a2                	ld	s1,40(sp)
    80004254:	7902                	ld	s2,32(sp)
    80004256:	69e2                	ld	s3,24(sp)
    80004258:	6a42                	ld	s4,16(sp)
    8000425a:	6aa2                	ld	s5,8(sp)
    8000425c:	6b02                	ld	s6,0(sp)
    8000425e:	6121                	add	sp,sp,64
    80004260:	8082                	ret
    80004262:	8082                	ret

0000000080004264 <initlog>:
{
    80004264:	7179                	add	sp,sp,-48
    80004266:	f406                	sd	ra,40(sp)
    80004268:	f022                	sd	s0,32(sp)
    8000426a:	ec26                	sd	s1,24(sp)
    8000426c:	e84a                	sd	s2,16(sp)
    8000426e:	e44e                	sd	s3,8(sp)
    80004270:	1800                	add	s0,sp,48
    80004272:	892a                	mv	s2,a0
    80004274:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004276:	00020497          	auipc	s1,0x20
    8000427a:	83a48493          	add	s1,s1,-1990 # 80023ab0 <log>
    8000427e:	00004597          	auipc	a1,0x4
    80004282:	3e258593          	add	a1,a1,994 # 80008660 <states.0+0x158>
    80004286:	8526                	mv	a0,s1
    80004288:	ffffd097          	auipc	ra,0xffffd
    8000428c:	920080e7          	jalr	-1760(ra) # 80000ba8 <initlock>
  log.start = sb->logstart;
    80004290:	0149a583          	lw	a1,20(s3)
    80004294:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004296:	0109a783          	lw	a5,16(s3)
    8000429a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000429c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800042a0:	854a                	mv	a0,s2
    800042a2:	fffff097          	auipc	ra,0xfffff
    800042a6:	e58080e7          	jalr	-424(ra) # 800030fa <bread>
  log.lh.n = lh->n;
    800042aa:	4d30                	lw	a2,88(a0)
    800042ac:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800042ae:	00c05f63          	blez	a2,800042cc <initlog+0x68>
    800042b2:	87aa                	mv	a5,a0
    800042b4:	00020717          	auipc	a4,0x20
    800042b8:	82c70713          	add	a4,a4,-2004 # 80023ae0 <log+0x30>
    800042bc:	060a                	sll	a2,a2,0x2
    800042be:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800042c0:	4ff4                	lw	a3,92(a5)
    800042c2:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800042c4:	0791                	add	a5,a5,4
    800042c6:	0711                	add	a4,a4,4
    800042c8:	fec79ce3          	bne	a5,a2,800042c0 <initlog+0x5c>
  brelse(buf);
    800042cc:	fffff097          	auipc	ra,0xfffff
    800042d0:	f5e080e7          	jalr	-162(ra) # 8000322a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800042d4:	4505                	li	a0,1
    800042d6:	00000097          	auipc	ra,0x0
    800042da:	eca080e7          	jalr	-310(ra) # 800041a0 <install_trans>
  log.lh.n = 0;
    800042de:	0001f797          	auipc	a5,0x1f
    800042e2:	7e07af23          	sw	zero,2046(a5) # 80023adc <log+0x2c>
  write_head(); // clear the log
    800042e6:	00000097          	auipc	ra,0x0
    800042ea:	e50080e7          	jalr	-432(ra) # 80004136 <write_head>
}
    800042ee:	70a2                	ld	ra,40(sp)
    800042f0:	7402                	ld	s0,32(sp)
    800042f2:	64e2                	ld	s1,24(sp)
    800042f4:	6942                	ld	s2,16(sp)
    800042f6:	69a2                	ld	s3,8(sp)
    800042f8:	6145                	add	sp,sp,48
    800042fa:	8082                	ret

00000000800042fc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800042fc:	1101                	add	sp,sp,-32
    800042fe:	ec06                	sd	ra,24(sp)
    80004300:	e822                	sd	s0,16(sp)
    80004302:	e426                	sd	s1,8(sp)
    80004304:	e04a                	sd	s2,0(sp)
    80004306:	1000                	add	s0,sp,32
  acquire(&log.lock);
    80004308:	0001f517          	auipc	a0,0x1f
    8000430c:	7a850513          	add	a0,a0,1960 # 80023ab0 <log>
    80004310:	ffffd097          	auipc	ra,0xffffd
    80004314:	928080e7          	jalr	-1752(ra) # 80000c38 <acquire>
  while(1){
    if(log.committing){
    80004318:	0001f497          	auipc	s1,0x1f
    8000431c:	79848493          	add	s1,s1,1944 # 80023ab0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004320:	4979                	li	s2,30
    80004322:	a039                	j	80004330 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004324:	85a6                	mv	a1,s1
    80004326:	8526                	mv	a0,s1
    80004328:	ffffe097          	auipc	ra,0xffffe
    8000432c:	dd8080e7          	jalr	-552(ra) # 80002100 <sleep>
    if(log.committing){
    80004330:	50dc                	lw	a5,36(s1)
    80004332:	fbed                	bnez	a5,80004324 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004334:	5098                	lw	a4,32(s1)
    80004336:	2705                	addw	a4,a4,1
    80004338:	0027179b          	sllw	a5,a4,0x2
    8000433c:	9fb9                	addw	a5,a5,a4
    8000433e:	0017979b          	sllw	a5,a5,0x1
    80004342:	54d4                	lw	a3,44(s1)
    80004344:	9fb5                	addw	a5,a5,a3
    80004346:	00f95963          	bge	s2,a5,80004358 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000434a:	85a6                	mv	a1,s1
    8000434c:	8526                	mv	a0,s1
    8000434e:	ffffe097          	auipc	ra,0xffffe
    80004352:	db2080e7          	jalr	-590(ra) # 80002100 <sleep>
    80004356:	bfe9                	j	80004330 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004358:	0001f517          	auipc	a0,0x1f
    8000435c:	75850513          	add	a0,a0,1880 # 80023ab0 <log>
    80004360:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004362:	ffffd097          	auipc	ra,0xffffd
    80004366:	98a080e7          	jalr	-1654(ra) # 80000cec <release>
      break;
    }
  }
}
    8000436a:	60e2                	ld	ra,24(sp)
    8000436c:	6442                	ld	s0,16(sp)
    8000436e:	64a2                	ld	s1,8(sp)
    80004370:	6902                	ld	s2,0(sp)
    80004372:	6105                	add	sp,sp,32
    80004374:	8082                	ret

0000000080004376 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004376:	7139                	add	sp,sp,-64
    80004378:	fc06                	sd	ra,56(sp)
    8000437a:	f822                	sd	s0,48(sp)
    8000437c:	f426                	sd	s1,40(sp)
    8000437e:	f04a                	sd	s2,32(sp)
    80004380:	0080                	add	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004382:	0001f497          	auipc	s1,0x1f
    80004386:	72e48493          	add	s1,s1,1838 # 80023ab0 <log>
    8000438a:	8526                	mv	a0,s1
    8000438c:	ffffd097          	auipc	ra,0xffffd
    80004390:	8ac080e7          	jalr	-1876(ra) # 80000c38 <acquire>
  log.outstanding -= 1;
    80004394:	509c                	lw	a5,32(s1)
    80004396:	37fd                	addw	a5,a5,-1
    80004398:	0007891b          	sext.w	s2,a5
    8000439c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000439e:	50dc                	lw	a5,36(s1)
    800043a0:	e7b9                	bnez	a5,800043ee <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    800043a2:	06091163          	bnez	s2,80004404 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800043a6:	0001f497          	auipc	s1,0x1f
    800043aa:	70a48493          	add	s1,s1,1802 # 80023ab0 <log>
    800043ae:	4785                	li	a5,1
    800043b0:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800043b2:	8526                	mv	a0,s1
    800043b4:	ffffd097          	auipc	ra,0xffffd
    800043b8:	938080e7          	jalr	-1736(ra) # 80000cec <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800043bc:	54dc                	lw	a5,44(s1)
    800043be:	06f04763          	bgtz	a5,8000442c <end_op+0xb6>
    acquire(&log.lock);
    800043c2:	0001f497          	auipc	s1,0x1f
    800043c6:	6ee48493          	add	s1,s1,1774 # 80023ab0 <log>
    800043ca:	8526                	mv	a0,s1
    800043cc:	ffffd097          	auipc	ra,0xffffd
    800043d0:	86c080e7          	jalr	-1940(ra) # 80000c38 <acquire>
    log.committing = 0;
    800043d4:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800043d8:	8526                	mv	a0,s1
    800043da:	ffffe097          	auipc	ra,0xffffe
    800043de:	d90080e7          	jalr	-624(ra) # 8000216a <wakeup>
    release(&log.lock);
    800043e2:	8526                	mv	a0,s1
    800043e4:	ffffd097          	auipc	ra,0xffffd
    800043e8:	908080e7          	jalr	-1784(ra) # 80000cec <release>
}
    800043ec:	a815                	j	80004420 <end_op+0xaa>
    800043ee:	ec4e                	sd	s3,24(sp)
    800043f0:	e852                	sd	s4,16(sp)
    800043f2:	e456                	sd	s5,8(sp)
    panic("log.committing");
    800043f4:	00004517          	auipc	a0,0x4
    800043f8:	27450513          	add	a0,a0,628 # 80008668 <states.0+0x160>
    800043fc:	ffffc097          	auipc	ra,0xffffc
    80004400:	164080e7          	jalr	356(ra) # 80000560 <panic>
    wakeup(&log);
    80004404:	0001f497          	auipc	s1,0x1f
    80004408:	6ac48493          	add	s1,s1,1708 # 80023ab0 <log>
    8000440c:	8526                	mv	a0,s1
    8000440e:	ffffe097          	auipc	ra,0xffffe
    80004412:	d5c080e7          	jalr	-676(ra) # 8000216a <wakeup>
  release(&log.lock);
    80004416:	8526                	mv	a0,s1
    80004418:	ffffd097          	auipc	ra,0xffffd
    8000441c:	8d4080e7          	jalr	-1836(ra) # 80000cec <release>
}
    80004420:	70e2                	ld	ra,56(sp)
    80004422:	7442                	ld	s0,48(sp)
    80004424:	74a2                	ld	s1,40(sp)
    80004426:	7902                	ld	s2,32(sp)
    80004428:	6121                	add	sp,sp,64
    8000442a:	8082                	ret
    8000442c:	ec4e                	sd	s3,24(sp)
    8000442e:	e852                	sd	s4,16(sp)
    80004430:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004432:	0001fa97          	auipc	s5,0x1f
    80004436:	6aea8a93          	add	s5,s5,1710 # 80023ae0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000443a:	0001fa17          	auipc	s4,0x1f
    8000443e:	676a0a13          	add	s4,s4,1654 # 80023ab0 <log>
    80004442:	018a2583          	lw	a1,24(s4)
    80004446:	012585bb          	addw	a1,a1,s2
    8000444a:	2585                	addw	a1,a1,1
    8000444c:	028a2503          	lw	a0,40(s4)
    80004450:	fffff097          	auipc	ra,0xfffff
    80004454:	caa080e7          	jalr	-854(ra) # 800030fa <bread>
    80004458:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000445a:	000aa583          	lw	a1,0(s5)
    8000445e:	028a2503          	lw	a0,40(s4)
    80004462:	fffff097          	auipc	ra,0xfffff
    80004466:	c98080e7          	jalr	-872(ra) # 800030fa <bread>
    8000446a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000446c:	40000613          	li	a2,1024
    80004470:	05850593          	add	a1,a0,88
    80004474:	05848513          	add	a0,s1,88
    80004478:	ffffd097          	auipc	ra,0xffffd
    8000447c:	918080e7          	jalr	-1768(ra) # 80000d90 <memmove>
    bwrite(to);  // write the log
    80004480:	8526                	mv	a0,s1
    80004482:	fffff097          	auipc	ra,0xfffff
    80004486:	d6a080e7          	jalr	-662(ra) # 800031ec <bwrite>
    brelse(from);
    8000448a:	854e                	mv	a0,s3
    8000448c:	fffff097          	auipc	ra,0xfffff
    80004490:	d9e080e7          	jalr	-610(ra) # 8000322a <brelse>
    brelse(to);
    80004494:	8526                	mv	a0,s1
    80004496:	fffff097          	auipc	ra,0xfffff
    8000449a:	d94080e7          	jalr	-620(ra) # 8000322a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000449e:	2905                	addw	s2,s2,1
    800044a0:	0a91                	add	s5,s5,4
    800044a2:	02ca2783          	lw	a5,44(s4)
    800044a6:	f8f94ee3          	blt	s2,a5,80004442 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800044aa:	00000097          	auipc	ra,0x0
    800044ae:	c8c080e7          	jalr	-884(ra) # 80004136 <write_head>
    install_trans(0); // Now install writes to home locations
    800044b2:	4501                	li	a0,0
    800044b4:	00000097          	auipc	ra,0x0
    800044b8:	cec080e7          	jalr	-788(ra) # 800041a0 <install_trans>
    log.lh.n = 0;
    800044bc:	0001f797          	auipc	a5,0x1f
    800044c0:	6207a023          	sw	zero,1568(a5) # 80023adc <log+0x2c>
    write_head();    // Erase the transaction from the log
    800044c4:	00000097          	auipc	ra,0x0
    800044c8:	c72080e7          	jalr	-910(ra) # 80004136 <write_head>
    800044cc:	69e2                	ld	s3,24(sp)
    800044ce:	6a42                	ld	s4,16(sp)
    800044d0:	6aa2                	ld	s5,8(sp)
    800044d2:	bdc5                	j	800043c2 <end_op+0x4c>

00000000800044d4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800044d4:	1101                	add	sp,sp,-32
    800044d6:	ec06                	sd	ra,24(sp)
    800044d8:	e822                	sd	s0,16(sp)
    800044da:	e426                	sd	s1,8(sp)
    800044dc:	e04a                	sd	s2,0(sp)
    800044de:	1000                	add	s0,sp,32
    800044e0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800044e2:	0001f917          	auipc	s2,0x1f
    800044e6:	5ce90913          	add	s2,s2,1486 # 80023ab0 <log>
    800044ea:	854a                	mv	a0,s2
    800044ec:	ffffc097          	auipc	ra,0xffffc
    800044f0:	74c080e7          	jalr	1868(ra) # 80000c38 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800044f4:	02c92603          	lw	a2,44(s2)
    800044f8:	47f5                	li	a5,29
    800044fa:	06c7c563          	blt	a5,a2,80004564 <log_write+0x90>
    800044fe:	0001f797          	auipc	a5,0x1f
    80004502:	5ce7a783          	lw	a5,1486(a5) # 80023acc <log+0x1c>
    80004506:	37fd                	addw	a5,a5,-1
    80004508:	04f65e63          	bge	a2,a5,80004564 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000450c:	0001f797          	auipc	a5,0x1f
    80004510:	5c47a783          	lw	a5,1476(a5) # 80023ad0 <log+0x20>
    80004514:	06f05063          	blez	a5,80004574 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004518:	4781                	li	a5,0
    8000451a:	06c05563          	blez	a2,80004584 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000451e:	44cc                	lw	a1,12(s1)
    80004520:	0001f717          	auipc	a4,0x1f
    80004524:	5c070713          	add	a4,a4,1472 # 80023ae0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004528:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000452a:	4314                	lw	a3,0(a4)
    8000452c:	04b68c63          	beq	a3,a1,80004584 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004530:	2785                	addw	a5,a5,1
    80004532:	0711                	add	a4,a4,4
    80004534:	fef61be3          	bne	a2,a5,8000452a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004538:	0621                	add	a2,a2,8
    8000453a:	060a                	sll	a2,a2,0x2
    8000453c:	0001f797          	auipc	a5,0x1f
    80004540:	57478793          	add	a5,a5,1396 # 80023ab0 <log>
    80004544:	97b2                	add	a5,a5,a2
    80004546:	44d8                	lw	a4,12(s1)
    80004548:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000454a:	8526                	mv	a0,s1
    8000454c:	fffff097          	auipc	ra,0xfffff
    80004550:	d7a080e7          	jalr	-646(ra) # 800032c6 <bpin>
    log.lh.n++;
    80004554:	0001f717          	auipc	a4,0x1f
    80004558:	55c70713          	add	a4,a4,1372 # 80023ab0 <log>
    8000455c:	575c                	lw	a5,44(a4)
    8000455e:	2785                	addw	a5,a5,1
    80004560:	d75c                	sw	a5,44(a4)
    80004562:	a82d                	j	8000459c <log_write+0xc8>
    panic("too big a transaction");
    80004564:	00004517          	auipc	a0,0x4
    80004568:	11450513          	add	a0,a0,276 # 80008678 <states.0+0x170>
    8000456c:	ffffc097          	auipc	ra,0xffffc
    80004570:	ff4080e7          	jalr	-12(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    80004574:	00004517          	auipc	a0,0x4
    80004578:	11c50513          	add	a0,a0,284 # 80008690 <states.0+0x188>
    8000457c:	ffffc097          	auipc	ra,0xffffc
    80004580:	fe4080e7          	jalr	-28(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    80004584:	00878693          	add	a3,a5,8
    80004588:	068a                	sll	a3,a3,0x2
    8000458a:	0001f717          	auipc	a4,0x1f
    8000458e:	52670713          	add	a4,a4,1318 # 80023ab0 <log>
    80004592:	9736                	add	a4,a4,a3
    80004594:	44d4                	lw	a3,12(s1)
    80004596:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004598:	faf609e3          	beq	a2,a5,8000454a <log_write+0x76>
  }
  release(&log.lock);
    8000459c:	0001f517          	auipc	a0,0x1f
    800045a0:	51450513          	add	a0,a0,1300 # 80023ab0 <log>
    800045a4:	ffffc097          	auipc	ra,0xffffc
    800045a8:	748080e7          	jalr	1864(ra) # 80000cec <release>
}
    800045ac:	60e2                	ld	ra,24(sp)
    800045ae:	6442                	ld	s0,16(sp)
    800045b0:	64a2                	ld	s1,8(sp)
    800045b2:	6902                	ld	s2,0(sp)
    800045b4:	6105                	add	sp,sp,32
    800045b6:	8082                	ret

00000000800045b8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800045b8:	1101                	add	sp,sp,-32
    800045ba:	ec06                	sd	ra,24(sp)
    800045bc:	e822                	sd	s0,16(sp)
    800045be:	e426                	sd	s1,8(sp)
    800045c0:	e04a                	sd	s2,0(sp)
    800045c2:	1000                	add	s0,sp,32
    800045c4:	84aa                	mv	s1,a0
    800045c6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800045c8:	00004597          	auipc	a1,0x4
    800045cc:	0e858593          	add	a1,a1,232 # 800086b0 <states.0+0x1a8>
    800045d0:	0521                	add	a0,a0,8
    800045d2:	ffffc097          	auipc	ra,0xffffc
    800045d6:	5d6080e7          	jalr	1494(ra) # 80000ba8 <initlock>
  lk->name = name;
    800045da:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800045de:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045e2:	0204a423          	sw	zero,40(s1)
}
    800045e6:	60e2                	ld	ra,24(sp)
    800045e8:	6442                	ld	s0,16(sp)
    800045ea:	64a2                	ld	s1,8(sp)
    800045ec:	6902                	ld	s2,0(sp)
    800045ee:	6105                	add	sp,sp,32
    800045f0:	8082                	ret

00000000800045f2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800045f2:	1101                	add	sp,sp,-32
    800045f4:	ec06                	sd	ra,24(sp)
    800045f6:	e822                	sd	s0,16(sp)
    800045f8:	e426                	sd	s1,8(sp)
    800045fa:	e04a                	sd	s2,0(sp)
    800045fc:	1000                	add	s0,sp,32
    800045fe:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004600:	00850913          	add	s2,a0,8
    80004604:	854a                	mv	a0,s2
    80004606:	ffffc097          	auipc	ra,0xffffc
    8000460a:	632080e7          	jalr	1586(ra) # 80000c38 <acquire>
  while (lk->locked) {
    8000460e:	409c                	lw	a5,0(s1)
    80004610:	cb89                	beqz	a5,80004622 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004612:	85ca                	mv	a1,s2
    80004614:	8526                	mv	a0,s1
    80004616:	ffffe097          	auipc	ra,0xffffe
    8000461a:	aea080e7          	jalr	-1302(ra) # 80002100 <sleep>
  while (lk->locked) {
    8000461e:	409c                	lw	a5,0(s1)
    80004620:	fbed                	bnez	a5,80004612 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004622:	4785                	li	a5,1
    80004624:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004626:	ffffd097          	auipc	ra,0xffffd
    8000462a:	424080e7          	jalr	1060(ra) # 80001a4a <myproc>
    8000462e:	591c                	lw	a5,48(a0)
    80004630:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004632:	854a                	mv	a0,s2
    80004634:	ffffc097          	auipc	ra,0xffffc
    80004638:	6b8080e7          	jalr	1720(ra) # 80000cec <release>
}
    8000463c:	60e2                	ld	ra,24(sp)
    8000463e:	6442                	ld	s0,16(sp)
    80004640:	64a2                	ld	s1,8(sp)
    80004642:	6902                	ld	s2,0(sp)
    80004644:	6105                	add	sp,sp,32
    80004646:	8082                	ret

0000000080004648 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004648:	1101                	add	sp,sp,-32
    8000464a:	ec06                	sd	ra,24(sp)
    8000464c:	e822                	sd	s0,16(sp)
    8000464e:	e426                	sd	s1,8(sp)
    80004650:	e04a                	sd	s2,0(sp)
    80004652:	1000                	add	s0,sp,32
    80004654:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004656:	00850913          	add	s2,a0,8
    8000465a:	854a                	mv	a0,s2
    8000465c:	ffffc097          	auipc	ra,0xffffc
    80004660:	5dc080e7          	jalr	1500(ra) # 80000c38 <acquire>
  lk->locked = 0;
    80004664:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004668:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000466c:	8526                	mv	a0,s1
    8000466e:	ffffe097          	auipc	ra,0xffffe
    80004672:	afc080e7          	jalr	-1284(ra) # 8000216a <wakeup>
  release(&lk->lk);
    80004676:	854a                	mv	a0,s2
    80004678:	ffffc097          	auipc	ra,0xffffc
    8000467c:	674080e7          	jalr	1652(ra) # 80000cec <release>
}
    80004680:	60e2                	ld	ra,24(sp)
    80004682:	6442                	ld	s0,16(sp)
    80004684:	64a2                	ld	s1,8(sp)
    80004686:	6902                	ld	s2,0(sp)
    80004688:	6105                	add	sp,sp,32
    8000468a:	8082                	ret

000000008000468c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000468c:	7179                	add	sp,sp,-48
    8000468e:	f406                	sd	ra,40(sp)
    80004690:	f022                	sd	s0,32(sp)
    80004692:	ec26                	sd	s1,24(sp)
    80004694:	e84a                	sd	s2,16(sp)
    80004696:	1800                	add	s0,sp,48
    80004698:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000469a:	00850913          	add	s2,a0,8
    8000469e:	854a                	mv	a0,s2
    800046a0:	ffffc097          	auipc	ra,0xffffc
    800046a4:	598080e7          	jalr	1432(ra) # 80000c38 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800046a8:	409c                	lw	a5,0(s1)
    800046aa:	ef91                	bnez	a5,800046c6 <holdingsleep+0x3a>
    800046ac:	4481                	li	s1,0
  release(&lk->lk);
    800046ae:	854a                	mv	a0,s2
    800046b0:	ffffc097          	auipc	ra,0xffffc
    800046b4:	63c080e7          	jalr	1596(ra) # 80000cec <release>
  return r;
}
    800046b8:	8526                	mv	a0,s1
    800046ba:	70a2                	ld	ra,40(sp)
    800046bc:	7402                	ld	s0,32(sp)
    800046be:	64e2                	ld	s1,24(sp)
    800046c0:	6942                	ld	s2,16(sp)
    800046c2:	6145                	add	sp,sp,48
    800046c4:	8082                	ret
    800046c6:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800046c8:	0284a983          	lw	s3,40(s1)
    800046cc:	ffffd097          	auipc	ra,0xffffd
    800046d0:	37e080e7          	jalr	894(ra) # 80001a4a <myproc>
    800046d4:	5904                	lw	s1,48(a0)
    800046d6:	413484b3          	sub	s1,s1,s3
    800046da:	0014b493          	seqz	s1,s1
    800046de:	69a2                	ld	s3,8(sp)
    800046e0:	b7f9                	j	800046ae <holdingsleep+0x22>

00000000800046e2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800046e2:	1141                	add	sp,sp,-16
    800046e4:	e406                	sd	ra,8(sp)
    800046e6:	e022                	sd	s0,0(sp)
    800046e8:	0800                	add	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800046ea:	00004597          	auipc	a1,0x4
    800046ee:	fd658593          	add	a1,a1,-42 # 800086c0 <states.0+0x1b8>
    800046f2:	0001f517          	auipc	a0,0x1f
    800046f6:	50650513          	add	a0,a0,1286 # 80023bf8 <ftable>
    800046fa:	ffffc097          	auipc	ra,0xffffc
    800046fe:	4ae080e7          	jalr	1198(ra) # 80000ba8 <initlock>
}
    80004702:	60a2                	ld	ra,8(sp)
    80004704:	6402                	ld	s0,0(sp)
    80004706:	0141                	add	sp,sp,16
    80004708:	8082                	ret

000000008000470a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000470a:	1101                	add	sp,sp,-32
    8000470c:	ec06                	sd	ra,24(sp)
    8000470e:	e822                	sd	s0,16(sp)
    80004710:	e426                	sd	s1,8(sp)
    80004712:	1000                	add	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004714:	0001f517          	auipc	a0,0x1f
    80004718:	4e450513          	add	a0,a0,1252 # 80023bf8 <ftable>
    8000471c:	ffffc097          	auipc	ra,0xffffc
    80004720:	51c080e7          	jalr	1308(ra) # 80000c38 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004724:	0001f497          	auipc	s1,0x1f
    80004728:	4ec48493          	add	s1,s1,1260 # 80023c10 <ftable+0x18>
    8000472c:	00020717          	auipc	a4,0x20
    80004730:	48470713          	add	a4,a4,1156 # 80024bb0 <disk>
    if(f->ref == 0){
    80004734:	40dc                	lw	a5,4(s1)
    80004736:	cf99                	beqz	a5,80004754 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004738:	02848493          	add	s1,s1,40
    8000473c:	fee49ce3          	bne	s1,a4,80004734 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004740:	0001f517          	auipc	a0,0x1f
    80004744:	4b850513          	add	a0,a0,1208 # 80023bf8 <ftable>
    80004748:	ffffc097          	auipc	ra,0xffffc
    8000474c:	5a4080e7          	jalr	1444(ra) # 80000cec <release>
  return 0;
    80004750:	4481                	li	s1,0
    80004752:	a819                	j	80004768 <filealloc+0x5e>
      f->ref = 1;
    80004754:	4785                	li	a5,1
    80004756:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004758:	0001f517          	auipc	a0,0x1f
    8000475c:	4a050513          	add	a0,a0,1184 # 80023bf8 <ftable>
    80004760:	ffffc097          	auipc	ra,0xffffc
    80004764:	58c080e7          	jalr	1420(ra) # 80000cec <release>
}
    80004768:	8526                	mv	a0,s1
    8000476a:	60e2                	ld	ra,24(sp)
    8000476c:	6442                	ld	s0,16(sp)
    8000476e:	64a2                	ld	s1,8(sp)
    80004770:	6105                	add	sp,sp,32
    80004772:	8082                	ret

0000000080004774 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004774:	1101                	add	sp,sp,-32
    80004776:	ec06                	sd	ra,24(sp)
    80004778:	e822                	sd	s0,16(sp)
    8000477a:	e426                	sd	s1,8(sp)
    8000477c:	1000                	add	s0,sp,32
    8000477e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004780:	0001f517          	auipc	a0,0x1f
    80004784:	47850513          	add	a0,a0,1144 # 80023bf8 <ftable>
    80004788:	ffffc097          	auipc	ra,0xffffc
    8000478c:	4b0080e7          	jalr	1200(ra) # 80000c38 <acquire>
  if(f->ref < 1)
    80004790:	40dc                	lw	a5,4(s1)
    80004792:	02f05263          	blez	a5,800047b6 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004796:	2785                	addw	a5,a5,1
    80004798:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000479a:	0001f517          	auipc	a0,0x1f
    8000479e:	45e50513          	add	a0,a0,1118 # 80023bf8 <ftable>
    800047a2:	ffffc097          	auipc	ra,0xffffc
    800047a6:	54a080e7          	jalr	1354(ra) # 80000cec <release>
  return f;
}
    800047aa:	8526                	mv	a0,s1
    800047ac:	60e2                	ld	ra,24(sp)
    800047ae:	6442                	ld	s0,16(sp)
    800047b0:	64a2                	ld	s1,8(sp)
    800047b2:	6105                	add	sp,sp,32
    800047b4:	8082                	ret
    panic("filedup");
    800047b6:	00004517          	auipc	a0,0x4
    800047ba:	f1250513          	add	a0,a0,-238 # 800086c8 <states.0+0x1c0>
    800047be:	ffffc097          	auipc	ra,0xffffc
    800047c2:	da2080e7          	jalr	-606(ra) # 80000560 <panic>

00000000800047c6 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800047c6:	7139                	add	sp,sp,-64
    800047c8:	fc06                	sd	ra,56(sp)
    800047ca:	f822                	sd	s0,48(sp)
    800047cc:	f426                	sd	s1,40(sp)
    800047ce:	0080                	add	s0,sp,64
    800047d0:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800047d2:	0001f517          	auipc	a0,0x1f
    800047d6:	42650513          	add	a0,a0,1062 # 80023bf8 <ftable>
    800047da:	ffffc097          	auipc	ra,0xffffc
    800047de:	45e080e7          	jalr	1118(ra) # 80000c38 <acquire>
  if(f->ref < 1)
    800047e2:	40dc                	lw	a5,4(s1)
    800047e4:	04f05c63          	blez	a5,8000483c <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    800047e8:	37fd                	addw	a5,a5,-1
    800047ea:	0007871b          	sext.w	a4,a5
    800047ee:	c0dc                	sw	a5,4(s1)
    800047f0:	06e04263          	bgtz	a4,80004854 <fileclose+0x8e>
    800047f4:	f04a                	sd	s2,32(sp)
    800047f6:	ec4e                	sd	s3,24(sp)
    800047f8:	e852                	sd	s4,16(sp)
    800047fa:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800047fc:	0004a903          	lw	s2,0(s1)
    80004800:	0094ca83          	lbu	s5,9(s1)
    80004804:	0104ba03          	ld	s4,16(s1)
    80004808:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000480c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004810:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004814:	0001f517          	auipc	a0,0x1f
    80004818:	3e450513          	add	a0,a0,996 # 80023bf8 <ftable>
    8000481c:	ffffc097          	auipc	ra,0xffffc
    80004820:	4d0080e7          	jalr	1232(ra) # 80000cec <release>

  if(ff.type == FD_PIPE){
    80004824:	4785                	li	a5,1
    80004826:	04f90463          	beq	s2,a5,8000486e <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000482a:	3979                	addw	s2,s2,-2
    8000482c:	4785                	li	a5,1
    8000482e:	0527fb63          	bgeu	a5,s2,80004884 <fileclose+0xbe>
    80004832:	7902                	ld	s2,32(sp)
    80004834:	69e2                	ld	s3,24(sp)
    80004836:	6a42                	ld	s4,16(sp)
    80004838:	6aa2                	ld	s5,8(sp)
    8000483a:	a02d                	j	80004864 <fileclose+0x9e>
    8000483c:	f04a                	sd	s2,32(sp)
    8000483e:	ec4e                	sd	s3,24(sp)
    80004840:	e852                	sd	s4,16(sp)
    80004842:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004844:	00004517          	auipc	a0,0x4
    80004848:	e8c50513          	add	a0,a0,-372 # 800086d0 <states.0+0x1c8>
    8000484c:	ffffc097          	auipc	ra,0xffffc
    80004850:	d14080e7          	jalr	-748(ra) # 80000560 <panic>
    release(&ftable.lock);
    80004854:	0001f517          	auipc	a0,0x1f
    80004858:	3a450513          	add	a0,a0,932 # 80023bf8 <ftable>
    8000485c:	ffffc097          	auipc	ra,0xffffc
    80004860:	490080e7          	jalr	1168(ra) # 80000cec <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004864:	70e2                	ld	ra,56(sp)
    80004866:	7442                	ld	s0,48(sp)
    80004868:	74a2                	ld	s1,40(sp)
    8000486a:	6121                	add	sp,sp,64
    8000486c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000486e:	85d6                	mv	a1,s5
    80004870:	8552                	mv	a0,s4
    80004872:	00000097          	auipc	ra,0x0
    80004876:	3a2080e7          	jalr	930(ra) # 80004c14 <pipeclose>
    8000487a:	7902                	ld	s2,32(sp)
    8000487c:	69e2                	ld	s3,24(sp)
    8000487e:	6a42                	ld	s4,16(sp)
    80004880:	6aa2                	ld	s5,8(sp)
    80004882:	b7cd                	j	80004864 <fileclose+0x9e>
    begin_op();
    80004884:	00000097          	auipc	ra,0x0
    80004888:	a78080e7          	jalr	-1416(ra) # 800042fc <begin_op>
    iput(ff.ip);
    8000488c:	854e                	mv	a0,s3
    8000488e:	fffff097          	auipc	ra,0xfffff
    80004892:	25e080e7          	jalr	606(ra) # 80003aec <iput>
    end_op();
    80004896:	00000097          	auipc	ra,0x0
    8000489a:	ae0080e7          	jalr	-1312(ra) # 80004376 <end_op>
    8000489e:	7902                	ld	s2,32(sp)
    800048a0:	69e2                	ld	s3,24(sp)
    800048a2:	6a42                	ld	s4,16(sp)
    800048a4:	6aa2                	ld	s5,8(sp)
    800048a6:	bf7d                	j	80004864 <fileclose+0x9e>

00000000800048a8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800048a8:	715d                	add	sp,sp,-80
    800048aa:	e486                	sd	ra,72(sp)
    800048ac:	e0a2                	sd	s0,64(sp)
    800048ae:	fc26                	sd	s1,56(sp)
    800048b0:	f44e                	sd	s3,40(sp)
    800048b2:	0880                	add	s0,sp,80
    800048b4:	84aa                	mv	s1,a0
    800048b6:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800048b8:	ffffd097          	auipc	ra,0xffffd
    800048bc:	192080e7          	jalr	402(ra) # 80001a4a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800048c0:	409c                	lw	a5,0(s1)
    800048c2:	37f9                	addw	a5,a5,-2
    800048c4:	4705                	li	a4,1
    800048c6:	04f76863          	bltu	a4,a5,80004916 <filestat+0x6e>
    800048ca:	f84a                	sd	s2,48(sp)
    800048cc:	892a                	mv	s2,a0
    ilock(f->ip);
    800048ce:	6c88                	ld	a0,24(s1)
    800048d0:	fffff097          	auipc	ra,0xfffff
    800048d4:	05e080e7          	jalr	94(ra) # 8000392e <ilock>
    stati(f->ip, &st);
    800048d8:	fb840593          	add	a1,s0,-72
    800048dc:	6c88                	ld	a0,24(s1)
    800048de:	fffff097          	auipc	ra,0xfffff
    800048e2:	2de080e7          	jalr	734(ra) # 80003bbc <stati>
    iunlock(f->ip);
    800048e6:	6c88                	ld	a0,24(s1)
    800048e8:	fffff097          	auipc	ra,0xfffff
    800048ec:	10c080e7          	jalr	268(ra) # 800039f4 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800048f0:	46e1                	li	a3,24
    800048f2:	fb840613          	add	a2,s0,-72
    800048f6:	85ce                	mv	a1,s3
    800048f8:	06893503          	ld	a0,104(s2)
    800048fc:	ffffd097          	auipc	ra,0xffffd
    80004900:	de6080e7          	jalr	-538(ra) # 800016e2 <copyout>
    80004904:	41f5551b          	sraw	a0,a0,0x1f
    80004908:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000490a:	60a6                	ld	ra,72(sp)
    8000490c:	6406                	ld	s0,64(sp)
    8000490e:	74e2                	ld	s1,56(sp)
    80004910:	79a2                	ld	s3,40(sp)
    80004912:	6161                	add	sp,sp,80
    80004914:	8082                	ret
  return -1;
    80004916:	557d                	li	a0,-1
    80004918:	bfcd                	j	8000490a <filestat+0x62>

000000008000491a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000491a:	7179                	add	sp,sp,-48
    8000491c:	f406                	sd	ra,40(sp)
    8000491e:	f022                	sd	s0,32(sp)
    80004920:	e84a                	sd	s2,16(sp)
    80004922:	1800                	add	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004924:	00854783          	lbu	a5,8(a0)
    80004928:	cbc5                	beqz	a5,800049d8 <fileread+0xbe>
    8000492a:	ec26                	sd	s1,24(sp)
    8000492c:	e44e                	sd	s3,8(sp)
    8000492e:	84aa                	mv	s1,a0
    80004930:	89ae                	mv	s3,a1
    80004932:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004934:	411c                	lw	a5,0(a0)
    80004936:	4705                	li	a4,1
    80004938:	04e78963          	beq	a5,a4,8000498a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000493c:	470d                	li	a4,3
    8000493e:	04e78f63          	beq	a5,a4,8000499c <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004942:	4709                	li	a4,2
    80004944:	08e79263          	bne	a5,a4,800049c8 <fileread+0xae>
    ilock(f->ip);
    80004948:	6d08                	ld	a0,24(a0)
    8000494a:	fffff097          	auipc	ra,0xfffff
    8000494e:	fe4080e7          	jalr	-28(ra) # 8000392e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004952:	874a                	mv	a4,s2
    80004954:	5094                	lw	a3,32(s1)
    80004956:	864e                	mv	a2,s3
    80004958:	4585                	li	a1,1
    8000495a:	6c88                	ld	a0,24(s1)
    8000495c:	fffff097          	auipc	ra,0xfffff
    80004960:	28a080e7          	jalr	650(ra) # 80003be6 <readi>
    80004964:	892a                	mv	s2,a0
    80004966:	00a05563          	blez	a0,80004970 <fileread+0x56>
      f->off += r;
    8000496a:	509c                	lw	a5,32(s1)
    8000496c:	9fa9                	addw	a5,a5,a0
    8000496e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004970:	6c88                	ld	a0,24(s1)
    80004972:	fffff097          	auipc	ra,0xfffff
    80004976:	082080e7          	jalr	130(ra) # 800039f4 <iunlock>
    8000497a:	64e2                	ld	s1,24(sp)
    8000497c:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000497e:	854a                	mv	a0,s2
    80004980:	70a2                	ld	ra,40(sp)
    80004982:	7402                	ld	s0,32(sp)
    80004984:	6942                	ld	s2,16(sp)
    80004986:	6145                	add	sp,sp,48
    80004988:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000498a:	6908                	ld	a0,16(a0)
    8000498c:	00000097          	auipc	ra,0x0
    80004990:	400080e7          	jalr	1024(ra) # 80004d8c <piperead>
    80004994:	892a                	mv	s2,a0
    80004996:	64e2                	ld	s1,24(sp)
    80004998:	69a2                	ld	s3,8(sp)
    8000499a:	b7d5                	j	8000497e <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000499c:	02451783          	lh	a5,36(a0)
    800049a0:	03079693          	sll	a3,a5,0x30
    800049a4:	92c1                	srl	a3,a3,0x30
    800049a6:	4725                	li	a4,9
    800049a8:	02d76a63          	bltu	a4,a3,800049dc <fileread+0xc2>
    800049ac:	0792                	sll	a5,a5,0x4
    800049ae:	0001f717          	auipc	a4,0x1f
    800049b2:	1aa70713          	add	a4,a4,426 # 80023b58 <devsw>
    800049b6:	97ba                	add	a5,a5,a4
    800049b8:	639c                	ld	a5,0(a5)
    800049ba:	c78d                	beqz	a5,800049e4 <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    800049bc:	4505                	li	a0,1
    800049be:	9782                	jalr	a5
    800049c0:	892a                	mv	s2,a0
    800049c2:	64e2                	ld	s1,24(sp)
    800049c4:	69a2                	ld	s3,8(sp)
    800049c6:	bf65                	j	8000497e <fileread+0x64>
    panic("fileread");
    800049c8:	00004517          	auipc	a0,0x4
    800049cc:	d1850513          	add	a0,a0,-744 # 800086e0 <states.0+0x1d8>
    800049d0:	ffffc097          	auipc	ra,0xffffc
    800049d4:	b90080e7          	jalr	-1136(ra) # 80000560 <panic>
    return -1;
    800049d8:	597d                	li	s2,-1
    800049da:	b755                	j	8000497e <fileread+0x64>
      return -1;
    800049dc:	597d                	li	s2,-1
    800049de:	64e2                	ld	s1,24(sp)
    800049e0:	69a2                	ld	s3,8(sp)
    800049e2:	bf71                	j	8000497e <fileread+0x64>
    800049e4:	597d                	li	s2,-1
    800049e6:	64e2                	ld	s1,24(sp)
    800049e8:	69a2                	ld	s3,8(sp)
    800049ea:	bf51                	j	8000497e <fileread+0x64>

00000000800049ec <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800049ec:	00954783          	lbu	a5,9(a0)
    800049f0:	12078963          	beqz	a5,80004b22 <filewrite+0x136>
{
    800049f4:	715d                	add	sp,sp,-80
    800049f6:	e486                	sd	ra,72(sp)
    800049f8:	e0a2                	sd	s0,64(sp)
    800049fa:	f84a                	sd	s2,48(sp)
    800049fc:	f052                	sd	s4,32(sp)
    800049fe:	e85a                	sd	s6,16(sp)
    80004a00:	0880                	add	s0,sp,80
    80004a02:	892a                	mv	s2,a0
    80004a04:	8b2e                	mv	s6,a1
    80004a06:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a08:	411c                	lw	a5,0(a0)
    80004a0a:	4705                	li	a4,1
    80004a0c:	02e78763          	beq	a5,a4,80004a3a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a10:	470d                	li	a4,3
    80004a12:	02e78a63          	beq	a5,a4,80004a46 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a16:	4709                	li	a4,2
    80004a18:	0ee79863          	bne	a5,a4,80004b08 <filewrite+0x11c>
    80004a1c:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a1e:	0cc05463          	blez	a2,80004ae6 <filewrite+0xfa>
    80004a22:	fc26                	sd	s1,56(sp)
    80004a24:	ec56                	sd	s5,24(sp)
    80004a26:	e45e                	sd	s7,8(sp)
    80004a28:	e062                	sd	s8,0(sp)
    int i = 0;
    80004a2a:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004a2c:	6b85                	lui	s7,0x1
    80004a2e:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004a32:	6c05                	lui	s8,0x1
    80004a34:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004a38:	a851                	j	80004acc <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004a3a:	6908                	ld	a0,16(a0)
    80004a3c:	00000097          	auipc	ra,0x0
    80004a40:	248080e7          	jalr	584(ra) # 80004c84 <pipewrite>
    80004a44:	a85d                	j	80004afa <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a46:	02451783          	lh	a5,36(a0)
    80004a4a:	03079693          	sll	a3,a5,0x30
    80004a4e:	92c1                	srl	a3,a3,0x30
    80004a50:	4725                	li	a4,9
    80004a52:	0cd76a63          	bltu	a4,a3,80004b26 <filewrite+0x13a>
    80004a56:	0792                	sll	a5,a5,0x4
    80004a58:	0001f717          	auipc	a4,0x1f
    80004a5c:	10070713          	add	a4,a4,256 # 80023b58 <devsw>
    80004a60:	97ba                	add	a5,a5,a4
    80004a62:	679c                	ld	a5,8(a5)
    80004a64:	c3f9                	beqz	a5,80004b2a <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    80004a66:	4505                	li	a0,1
    80004a68:	9782                	jalr	a5
    80004a6a:	a841                	j	80004afa <filewrite+0x10e>
      if(n1 > max)
    80004a6c:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004a70:	00000097          	auipc	ra,0x0
    80004a74:	88c080e7          	jalr	-1908(ra) # 800042fc <begin_op>
      ilock(f->ip);
    80004a78:	01893503          	ld	a0,24(s2)
    80004a7c:	fffff097          	auipc	ra,0xfffff
    80004a80:	eb2080e7          	jalr	-334(ra) # 8000392e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a84:	8756                	mv	a4,s5
    80004a86:	02092683          	lw	a3,32(s2)
    80004a8a:	01698633          	add	a2,s3,s6
    80004a8e:	4585                	li	a1,1
    80004a90:	01893503          	ld	a0,24(s2)
    80004a94:	fffff097          	auipc	ra,0xfffff
    80004a98:	262080e7          	jalr	610(ra) # 80003cf6 <writei>
    80004a9c:	84aa                	mv	s1,a0
    80004a9e:	00a05763          	blez	a0,80004aac <filewrite+0xc0>
        f->off += r;
    80004aa2:	02092783          	lw	a5,32(s2)
    80004aa6:	9fa9                	addw	a5,a5,a0
    80004aa8:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004aac:	01893503          	ld	a0,24(s2)
    80004ab0:	fffff097          	auipc	ra,0xfffff
    80004ab4:	f44080e7          	jalr	-188(ra) # 800039f4 <iunlock>
      end_op();
    80004ab8:	00000097          	auipc	ra,0x0
    80004abc:	8be080e7          	jalr	-1858(ra) # 80004376 <end_op>

      if(r != n1){
    80004ac0:	029a9563          	bne	s5,s1,80004aea <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    80004ac4:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004ac8:	0149da63          	bge	s3,s4,80004adc <filewrite+0xf0>
      int n1 = n - i;
    80004acc:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004ad0:	0004879b          	sext.w	a5,s1
    80004ad4:	f8fbdce3          	bge	s7,a5,80004a6c <filewrite+0x80>
    80004ad8:	84e2                	mv	s1,s8
    80004ada:	bf49                	j	80004a6c <filewrite+0x80>
    80004adc:	74e2                	ld	s1,56(sp)
    80004ade:	6ae2                	ld	s5,24(sp)
    80004ae0:	6ba2                	ld	s7,8(sp)
    80004ae2:	6c02                	ld	s8,0(sp)
    80004ae4:	a039                	j	80004af2 <filewrite+0x106>
    int i = 0;
    80004ae6:	4981                	li	s3,0
    80004ae8:	a029                	j	80004af2 <filewrite+0x106>
    80004aea:	74e2                	ld	s1,56(sp)
    80004aec:	6ae2                	ld	s5,24(sp)
    80004aee:	6ba2                	ld	s7,8(sp)
    80004af0:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004af2:	033a1e63          	bne	s4,s3,80004b2e <filewrite+0x142>
    80004af6:	8552                	mv	a0,s4
    80004af8:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004afa:	60a6                	ld	ra,72(sp)
    80004afc:	6406                	ld	s0,64(sp)
    80004afe:	7942                	ld	s2,48(sp)
    80004b00:	7a02                	ld	s4,32(sp)
    80004b02:	6b42                	ld	s6,16(sp)
    80004b04:	6161                	add	sp,sp,80
    80004b06:	8082                	ret
    80004b08:	fc26                	sd	s1,56(sp)
    80004b0a:	f44e                	sd	s3,40(sp)
    80004b0c:	ec56                	sd	s5,24(sp)
    80004b0e:	e45e                	sd	s7,8(sp)
    80004b10:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004b12:	00004517          	auipc	a0,0x4
    80004b16:	bde50513          	add	a0,a0,-1058 # 800086f0 <states.0+0x1e8>
    80004b1a:	ffffc097          	auipc	ra,0xffffc
    80004b1e:	a46080e7          	jalr	-1466(ra) # 80000560 <panic>
    return -1;
    80004b22:	557d                	li	a0,-1
}
    80004b24:	8082                	ret
      return -1;
    80004b26:	557d                	li	a0,-1
    80004b28:	bfc9                	j	80004afa <filewrite+0x10e>
    80004b2a:	557d                	li	a0,-1
    80004b2c:	b7f9                	j	80004afa <filewrite+0x10e>
    ret = (i == n ? n : -1);
    80004b2e:	557d                	li	a0,-1
    80004b30:	79a2                	ld	s3,40(sp)
    80004b32:	b7e1                	j	80004afa <filewrite+0x10e>

0000000080004b34 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b34:	7179                	add	sp,sp,-48
    80004b36:	f406                	sd	ra,40(sp)
    80004b38:	f022                	sd	s0,32(sp)
    80004b3a:	ec26                	sd	s1,24(sp)
    80004b3c:	e052                	sd	s4,0(sp)
    80004b3e:	1800                	add	s0,sp,48
    80004b40:	84aa                	mv	s1,a0
    80004b42:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b44:	0005b023          	sd	zero,0(a1)
    80004b48:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b4c:	00000097          	auipc	ra,0x0
    80004b50:	bbe080e7          	jalr	-1090(ra) # 8000470a <filealloc>
    80004b54:	e088                	sd	a0,0(s1)
    80004b56:	cd49                	beqz	a0,80004bf0 <pipealloc+0xbc>
    80004b58:	00000097          	auipc	ra,0x0
    80004b5c:	bb2080e7          	jalr	-1102(ra) # 8000470a <filealloc>
    80004b60:	00aa3023          	sd	a0,0(s4)
    80004b64:	c141                	beqz	a0,80004be4 <pipealloc+0xb0>
    80004b66:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b68:	ffffc097          	auipc	ra,0xffffc
    80004b6c:	fe0080e7          	jalr	-32(ra) # 80000b48 <kalloc>
    80004b70:	892a                	mv	s2,a0
    80004b72:	c13d                	beqz	a0,80004bd8 <pipealloc+0xa4>
    80004b74:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004b76:	4985                	li	s3,1
    80004b78:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b7c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b80:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b84:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b88:	00004597          	auipc	a1,0x4
    80004b8c:	b7858593          	add	a1,a1,-1160 # 80008700 <states.0+0x1f8>
    80004b90:	ffffc097          	auipc	ra,0xffffc
    80004b94:	018080e7          	jalr	24(ra) # 80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    80004b98:	609c                	ld	a5,0(s1)
    80004b9a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b9e:	609c                	ld	a5,0(s1)
    80004ba0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004ba4:	609c                	ld	a5,0(s1)
    80004ba6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004baa:	609c                	ld	a5,0(s1)
    80004bac:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004bb0:	000a3783          	ld	a5,0(s4)
    80004bb4:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004bb8:	000a3783          	ld	a5,0(s4)
    80004bbc:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004bc0:	000a3783          	ld	a5,0(s4)
    80004bc4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004bc8:	000a3783          	ld	a5,0(s4)
    80004bcc:	0127b823          	sd	s2,16(a5)
  return 0;
    80004bd0:	4501                	li	a0,0
    80004bd2:	6942                	ld	s2,16(sp)
    80004bd4:	69a2                	ld	s3,8(sp)
    80004bd6:	a03d                	j	80004c04 <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004bd8:	6088                	ld	a0,0(s1)
    80004bda:	c119                	beqz	a0,80004be0 <pipealloc+0xac>
    80004bdc:	6942                	ld	s2,16(sp)
    80004bde:	a029                	j	80004be8 <pipealloc+0xb4>
    80004be0:	6942                	ld	s2,16(sp)
    80004be2:	a039                	j	80004bf0 <pipealloc+0xbc>
    80004be4:	6088                	ld	a0,0(s1)
    80004be6:	c50d                	beqz	a0,80004c10 <pipealloc+0xdc>
    fileclose(*f0);
    80004be8:	00000097          	auipc	ra,0x0
    80004bec:	bde080e7          	jalr	-1058(ra) # 800047c6 <fileclose>
  if(*f1)
    80004bf0:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004bf4:	557d                	li	a0,-1
  if(*f1)
    80004bf6:	c799                	beqz	a5,80004c04 <pipealloc+0xd0>
    fileclose(*f1);
    80004bf8:	853e                	mv	a0,a5
    80004bfa:	00000097          	auipc	ra,0x0
    80004bfe:	bcc080e7          	jalr	-1076(ra) # 800047c6 <fileclose>
  return -1;
    80004c02:	557d                	li	a0,-1
}
    80004c04:	70a2                	ld	ra,40(sp)
    80004c06:	7402                	ld	s0,32(sp)
    80004c08:	64e2                	ld	s1,24(sp)
    80004c0a:	6a02                	ld	s4,0(sp)
    80004c0c:	6145                	add	sp,sp,48
    80004c0e:	8082                	ret
  return -1;
    80004c10:	557d                	li	a0,-1
    80004c12:	bfcd                	j	80004c04 <pipealloc+0xd0>

0000000080004c14 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c14:	1101                	add	sp,sp,-32
    80004c16:	ec06                	sd	ra,24(sp)
    80004c18:	e822                	sd	s0,16(sp)
    80004c1a:	e426                	sd	s1,8(sp)
    80004c1c:	e04a                	sd	s2,0(sp)
    80004c1e:	1000                	add	s0,sp,32
    80004c20:	84aa                	mv	s1,a0
    80004c22:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c24:	ffffc097          	auipc	ra,0xffffc
    80004c28:	014080e7          	jalr	20(ra) # 80000c38 <acquire>
  if(writable){
    80004c2c:	02090d63          	beqz	s2,80004c66 <pipeclose+0x52>
    pi->writeopen = 0;
    80004c30:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004c34:	21848513          	add	a0,s1,536
    80004c38:	ffffd097          	auipc	ra,0xffffd
    80004c3c:	532080e7          	jalr	1330(ra) # 8000216a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c40:	2204b783          	ld	a5,544(s1)
    80004c44:	eb95                	bnez	a5,80004c78 <pipeclose+0x64>
    release(&pi->lock);
    80004c46:	8526                	mv	a0,s1
    80004c48:	ffffc097          	auipc	ra,0xffffc
    80004c4c:	0a4080e7          	jalr	164(ra) # 80000cec <release>
    kfree((char*)pi);
    80004c50:	8526                	mv	a0,s1
    80004c52:	ffffc097          	auipc	ra,0xffffc
    80004c56:	df8080e7          	jalr	-520(ra) # 80000a4a <kfree>
  } else
    release(&pi->lock);
}
    80004c5a:	60e2                	ld	ra,24(sp)
    80004c5c:	6442                	ld	s0,16(sp)
    80004c5e:	64a2                	ld	s1,8(sp)
    80004c60:	6902                	ld	s2,0(sp)
    80004c62:	6105                	add	sp,sp,32
    80004c64:	8082                	ret
    pi->readopen = 0;
    80004c66:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c6a:	21c48513          	add	a0,s1,540
    80004c6e:	ffffd097          	auipc	ra,0xffffd
    80004c72:	4fc080e7          	jalr	1276(ra) # 8000216a <wakeup>
    80004c76:	b7e9                	j	80004c40 <pipeclose+0x2c>
    release(&pi->lock);
    80004c78:	8526                	mv	a0,s1
    80004c7a:	ffffc097          	auipc	ra,0xffffc
    80004c7e:	072080e7          	jalr	114(ra) # 80000cec <release>
}
    80004c82:	bfe1                	j	80004c5a <pipeclose+0x46>

0000000080004c84 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c84:	711d                	add	sp,sp,-96
    80004c86:	ec86                	sd	ra,88(sp)
    80004c88:	e8a2                	sd	s0,80(sp)
    80004c8a:	e4a6                	sd	s1,72(sp)
    80004c8c:	e0ca                	sd	s2,64(sp)
    80004c8e:	fc4e                	sd	s3,56(sp)
    80004c90:	f852                	sd	s4,48(sp)
    80004c92:	f456                	sd	s5,40(sp)
    80004c94:	1080                	add	s0,sp,96
    80004c96:	84aa                	mv	s1,a0
    80004c98:	8aae                	mv	s5,a1
    80004c9a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c9c:	ffffd097          	auipc	ra,0xffffd
    80004ca0:	dae080e7          	jalr	-594(ra) # 80001a4a <myproc>
    80004ca4:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004ca6:	8526                	mv	a0,s1
    80004ca8:	ffffc097          	auipc	ra,0xffffc
    80004cac:	f90080e7          	jalr	-112(ra) # 80000c38 <acquire>
  while(i < n){
    80004cb0:	0d405863          	blez	s4,80004d80 <pipewrite+0xfc>
    80004cb4:	f05a                	sd	s6,32(sp)
    80004cb6:	ec5e                	sd	s7,24(sp)
    80004cb8:	e862                	sd	s8,16(sp)
  int i = 0;
    80004cba:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cbc:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004cbe:	21848c13          	add	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004cc2:	21c48b93          	add	s7,s1,540
    80004cc6:	a089                	j	80004d08 <pipewrite+0x84>
      release(&pi->lock);
    80004cc8:	8526                	mv	a0,s1
    80004cca:	ffffc097          	auipc	ra,0xffffc
    80004cce:	022080e7          	jalr	34(ra) # 80000cec <release>
      return -1;
    80004cd2:	597d                	li	s2,-1
    80004cd4:	7b02                	ld	s6,32(sp)
    80004cd6:	6be2                	ld	s7,24(sp)
    80004cd8:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004cda:	854a                	mv	a0,s2
    80004cdc:	60e6                	ld	ra,88(sp)
    80004cde:	6446                	ld	s0,80(sp)
    80004ce0:	64a6                	ld	s1,72(sp)
    80004ce2:	6906                	ld	s2,64(sp)
    80004ce4:	79e2                	ld	s3,56(sp)
    80004ce6:	7a42                	ld	s4,48(sp)
    80004ce8:	7aa2                	ld	s5,40(sp)
    80004cea:	6125                	add	sp,sp,96
    80004cec:	8082                	ret
      wakeup(&pi->nread);
    80004cee:	8562                	mv	a0,s8
    80004cf0:	ffffd097          	auipc	ra,0xffffd
    80004cf4:	47a080e7          	jalr	1146(ra) # 8000216a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004cf8:	85a6                	mv	a1,s1
    80004cfa:	855e                	mv	a0,s7
    80004cfc:	ffffd097          	auipc	ra,0xffffd
    80004d00:	404080e7          	jalr	1028(ra) # 80002100 <sleep>
  while(i < n){
    80004d04:	05495f63          	bge	s2,s4,80004d62 <pipewrite+0xde>
    if(pi->readopen == 0 || killed(pr)){
    80004d08:	2204a783          	lw	a5,544(s1)
    80004d0c:	dfd5                	beqz	a5,80004cc8 <pipewrite+0x44>
    80004d0e:	854e                	mv	a0,s3
    80004d10:	ffffd097          	auipc	ra,0xffffd
    80004d14:	69e080e7          	jalr	1694(ra) # 800023ae <killed>
    80004d18:	f945                	bnez	a0,80004cc8 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004d1a:	2184a783          	lw	a5,536(s1)
    80004d1e:	21c4a703          	lw	a4,540(s1)
    80004d22:	2007879b          	addw	a5,a5,512
    80004d26:	fcf704e3          	beq	a4,a5,80004cee <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d2a:	4685                	li	a3,1
    80004d2c:	01590633          	add	a2,s2,s5
    80004d30:	faf40593          	add	a1,s0,-81
    80004d34:	0689b503          	ld	a0,104(s3)
    80004d38:	ffffd097          	auipc	ra,0xffffd
    80004d3c:	a36080e7          	jalr	-1482(ra) # 8000176e <copyin>
    80004d40:	05650263          	beq	a0,s6,80004d84 <pipewrite+0x100>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d44:	21c4a783          	lw	a5,540(s1)
    80004d48:	0017871b          	addw	a4,a5,1
    80004d4c:	20e4ae23          	sw	a4,540(s1)
    80004d50:	1ff7f793          	and	a5,a5,511
    80004d54:	97a6                	add	a5,a5,s1
    80004d56:	faf44703          	lbu	a4,-81(s0)
    80004d5a:	00e78c23          	sb	a4,24(a5)
      i++;
    80004d5e:	2905                	addw	s2,s2,1
    80004d60:	b755                	j	80004d04 <pipewrite+0x80>
    80004d62:	7b02                	ld	s6,32(sp)
    80004d64:	6be2                	ld	s7,24(sp)
    80004d66:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004d68:	21848513          	add	a0,s1,536
    80004d6c:	ffffd097          	auipc	ra,0xffffd
    80004d70:	3fe080e7          	jalr	1022(ra) # 8000216a <wakeup>
  release(&pi->lock);
    80004d74:	8526                	mv	a0,s1
    80004d76:	ffffc097          	auipc	ra,0xffffc
    80004d7a:	f76080e7          	jalr	-138(ra) # 80000cec <release>
  return i;
    80004d7e:	bfb1                	j	80004cda <pipewrite+0x56>
  int i = 0;
    80004d80:	4901                	li	s2,0
    80004d82:	b7dd                	j	80004d68 <pipewrite+0xe4>
    80004d84:	7b02                	ld	s6,32(sp)
    80004d86:	6be2                	ld	s7,24(sp)
    80004d88:	6c42                	ld	s8,16(sp)
    80004d8a:	bff9                	j	80004d68 <pipewrite+0xe4>

0000000080004d8c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d8c:	715d                	add	sp,sp,-80
    80004d8e:	e486                	sd	ra,72(sp)
    80004d90:	e0a2                	sd	s0,64(sp)
    80004d92:	fc26                	sd	s1,56(sp)
    80004d94:	f84a                	sd	s2,48(sp)
    80004d96:	f44e                	sd	s3,40(sp)
    80004d98:	f052                	sd	s4,32(sp)
    80004d9a:	ec56                	sd	s5,24(sp)
    80004d9c:	0880                	add	s0,sp,80
    80004d9e:	84aa                	mv	s1,a0
    80004da0:	892e                	mv	s2,a1
    80004da2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004da4:	ffffd097          	auipc	ra,0xffffd
    80004da8:	ca6080e7          	jalr	-858(ra) # 80001a4a <myproc>
    80004dac:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004dae:	8526                	mv	a0,s1
    80004db0:	ffffc097          	auipc	ra,0xffffc
    80004db4:	e88080e7          	jalr	-376(ra) # 80000c38 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004db8:	2184a703          	lw	a4,536(s1)
    80004dbc:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004dc0:	21848993          	add	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dc4:	02f71963          	bne	a4,a5,80004df6 <piperead+0x6a>
    80004dc8:	2244a783          	lw	a5,548(s1)
    80004dcc:	cf95                	beqz	a5,80004e08 <piperead+0x7c>
    if(killed(pr)){
    80004dce:	8552                	mv	a0,s4
    80004dd0:	ffffd097          	auipc	ra,0xffffd
    80004dd4:	5de080e7          	jalr	1502(ra) # 800023ae <killed>
    80004dd8:	e10d                	bnez	a0,80004dfa <piperead+0x6e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004dda:	85a6                	mv	a1,s1
    80004ddc:	854e                	mv	a0,s3
    80004dde:	ffffd097          	auipc	ra,0xffffd
    80004de2:	322080e7          	jalr	802(ra) # 80002100 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004de6:	2184a703          	lw	a4,536(s1)
    80004dea:	21c4a783          	lw	a5,540(s1)
    80004dee:	fcf70de3          	beq	a4,a5,80004dc8 <piperead+0x3c>
    80004df2:	e85a                	sd	s6,16(sp)
    80004df4:	a819                	j	80004e0a <piperead+0x7e>
    80004df6:	e85a                	sd	s6,16(sp)
    80004df8:	a809                	j	80004e0a <piperead+0x7e>
      release(&pi->lock);
    80004dfa:	8526                	mv	a0,s1
    80004dfc:	ffffc097          	auipc	ra,0xffffc
    80004e00:	ef0080e7          	jalr	-272(ra) # 80000cec <release>
      return -1;
    80004e04:	59fd                	li	s3,-1
    80004e06:	a0a5                	j	80004e6e <piperead+0xe2>
    80004e08:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e0a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e0c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e0e:	05505463          	blez	s5,80004e56 <piperead+0xca>
    if(pi->nread == pi->nwrite)
    80004e12:	2184a783          	lw	a5,536(s1)
    80004e16:	21c4a703          	lw	a4,540(s1)
    80004e1a:	02f70e63          	beq	a4,a5,80004e56 <piperead+0xca>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e1e:	0017871b          	addw	a4,a5,1
    80004e22:	20e4ac23          	sw	a4,536(s1)
    80004e26:	1ff7f793          	and	a5,a5,511
    80004e2a:	97a6                	add	a5,a5,s1
    80004e2c:	0187c783          	lbu	a5,24(a5)
    80004e30:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e34:	4685                	li	a3,1
    80004e36:	fbf40613          	add	a2,s0,-65
    80004e3a:	85ca                	mv	a1,s2
    80004e3c:	068a3503          	ld	a0,104(s4)
    80004e40:	ffffd097          	auipc	ra,0xffffd
    80004e44:	8a2080e7          	jalr	-1886(ra) # 800016e2 <copyout>
    80004e48:	01650763          	beq	a0,s6,80004e56 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e4c:	2985                	addw	s3,s3,1
    80004e4e:	0905                	add	s2,s2,1
    80004e50:	fd3a91e3          	bne	s5,s3,80004e12 <piperead+0x86>
    80004e54:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e56:	21c48513          	add	a0,s1,540
    80004e5a:	ffffd097          	auipc	ra,0xffffd
    80004e5e:	310080e7          	jalr	784(ra) # 8000216a <wakeup>
  release(&pi->lock);
    80004e62:	8526                	mv	a0,s1
    80004e64:	ffffc097          	auipc	ra,0xffffc
    80004e68:	e88080e7          	jalr	-376(ra) # 80000cec <release>
    80004e6c:	6b42                	ld	s6,16(sp)
  return i;
}
    80004e6e:	854e                	mv	a0,s3
    80004e70:	60a6                	ld	ra,72(sp)
    80004e72:	6406                	ld	s0,64(sp)
    80004e74:	74e2                	ld	s1,56(sp)
    80004e76:	7942                	ld	s2,48(sp)
    80004e78:	79a2                	ld	s3,40(sp)
    80004e7a:	7a02                	ld	s4,32(sp)
    80004e7c:	6ae2                	ld	s5,24(sp)
    80004e7e:	6161                	add	sp,sp,80
    80004e80:	8082                	ret

0000000080004e82 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004e82:	1141                	add	sp,sp,-16
    80004e84:	e422                	sd	s0,8(sp)
    80004e86:	0800                	add	s0,sp,16
    80004e88:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004e8a:	8905                	and	a0,a0,1
    80004e8c:	050e                	sll	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004e8e:	8b89                	and	a5,a5,2
    80004e90:	c399                	beqz	a5,80004e96 <flags2perm+0x14>
      perm |= PTE_W;
    80004e92:	00456513          	or	a0,a0,4
    return perm;
}
    80004e96:	6422                	ld	s0,8(sp)
    80004e98:	0141                	add	sp,sp,16
    80004e9a:	8082                	ret

0000000080004e9c <exec>:

int
exec(char *path, char **argv)
{
    80004e9c:	df010113          	add	sp,sp,-528
    80004ea0:	20113423          	sd	ra,520(sp)
    80004ea4:	20813023          	sd	s0,512(sp)
    80004ea8:	ffa6                	sd	s1,504(sp)
    80004eaa:	fbca                	sd	s2,496(sp)
    80004eac:	0c00                	add	s0,sp,528
    80004eae:	892a                	mv	s2,a0
    80004eb0:	dea43c23          	sd	a0,-520(s0)
    80004eb4:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004eb8:	ffffd097          	auipc	ra,0xffffd
    80004ebc:	b92080e7          	jalr	-1134(ra) # 80001a4a <myproc>
    80004ec0:	84aa                	mv	s1,a0

  begin_op();
    80004ec2:	fffff097          	auipc	ra,0xfffff
    80004ec6:	43a080e7          	jalr	1082(ra) # 800042fc <begin_op>

  if((ip = namei(path)) == 0){
    80004eca:	854a                	mv	a0,s2
    80004ecc:	fffff097          	auipc	ra,0xfffff
    80004ed0:	230080e7          	jalr	560(ra) # 800040fc <namei>
    80004ed4:	c135                	beqz	a0,80004f38 <exec+0x9c>
    80004ed6:	f3d2                	sd	s4,480(sp)
    80004ed8:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004eda:	fffff097          	auipc	ra,0xfffff
    80004ede:	a54080e7          	jalr	-1452(ra) # 8000392e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004ee2:	04000713          	li	a4,64
    80004ee6:	4681                	li	a3,0
    80004ee8:	e5040613          	add	a2,s0,-432
    80004eec:	4581                	li	a1,0
    80004eee:	8552                	mv	a0,s4
    80004ef0:	fffff097          	auipc	ra,0xfffff
    80004ef4:	cf6080e7          	jalr	-778(ra) # 80003be6 <readi>
    80004ef8:	04000793          	li	a5,64
    80004efc:	00f51a63          	bne	a0,a5,80004f10 <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004f00:	e5042703          	lw	a4,-432(s0)
    80004f04:	464c47b7          	lui	a5,0x464c4
    80004f08:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f0c:	02f70c63          	beq	a4,a5,80004f44 <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f10:	8552                	mv	a0,s4
    80004f12:	fffff097          	auipc	ra,0xfffff
    80004f16:	c82080e7          	jalr	-894(ra) # 80003b94 <iunlockput>
    end_op();
    80004f1a:	fffff097          	auipc	ra,0xfffff
    80004f1e:	45c080e7          	jalr	1116(ra) # 80004376 <end_op>
  }
  return -1;
    80004f22:	557d                	li	a0,-1
    80004f24:	7a1e                	ld	s4,480(sp)
}
    80004f26:	20813083          	ld	ra,520(sp)
    80004f2a:	20013403          	ld	s0,512(sp)
    80004f2e:	74fe                	ld	s1,504(sp)
    80004f30:	795e                	ld	s2,496(sp)
    80004f32:	21010113          	add	sp,sp,528
    80004f36:	8082                	ret
    end_op();
    80004f38:	fffff097          	auipc	ra,0xfffff
    80004f3c:	43e080e7          	jalr	1086(ra) # 80004376 <end_op>
    return -1;
    80004f40:	557d                	li	a0,-1
    80004f42:	b7d5                	j	80004f26 <exec+0x8a>
    80004f44:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004f46:	8526                	mv	a0,s1
    80004f48:	ffffd097          	auipc	ra,0xffffd
    80004f4c:	bc6080e7          	jalr	-1082(ra) # 80001b0e <proc_pagetable>
    80004f50:	8b2a                	mv	s6,a0
    80004f52:	30050f63          	beqz	a0,80005270 <exec+0x3d4>
    80004f56:	f7ce                	sd	s3,488(sp)
    80004f58:	efd6                	sd	s5,472(sp)
    80004f5a:	e7de                	sd	s7,456(sp)
    80004f5c:	e3e2                	sd	s8,448(sp)
    80004f5e:	ff66                	sd	s9,440(sp)
    80004f60:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f62:	e7042d03          	lw	s10,-400(s0)
    80004f66:	e8845783          	lhu	a5,-376(s0)
    80004f6a:	14078d63          	beqz	a5,800050c4 <exec+0x228>
    80004f6e:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f70:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f72:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004f74:	6c85                	lui	s9,0x1
    80004f76:	fffc8793          	add	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004f7a:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004f7e:	6a85                	lui	s5,0x1
    80004f80:	a0b5                	j	80004fec <exec+0x150>
      panic("loadseg: address should exist");
    80004f82:	00003517          	auipc	a0,0x3
    80004f86:	78650513          	add	a0,a0,1926 # 80008708 <states.0+0x200>
    80004f8a:	ffffb097          	auipc	ra,0xffffb
    80004f8e:	5d6080e7          	jalr	1494(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    80004f92:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f94:	8726                	mv	a4,s1
    80004f96:	012c06bb          	addw	a3,s8,s2
    80004f9a:	4581                	li	a1,0
    80004f9c:	8552                	mv	a0,s4
    80004f9e:	fffff097          	auipc	ra,0xfffff
    80004fa2:	c48080e7          	jalr	-952(ra) # 80003be6 <readi>
    80004fa6:	2501                	sext.w	a0,a0
    80004fa8:	28a49863          	bne	s1,a0,80005238 <exec+0x39c>
  for(i = 0; i < sz; i += PGSIZE){
    80004fac:	012a893b          	addw	s2,s5,s2
    80004fb0:	03397563          	bgeu	s2,s3,80004fda <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    80004fb4:	02091593          	sll	a1,s2,0x20
    80004fb8:	9181                	srl	a1,a1,0x20
    80004fba:	95de                	add	a1,a1,s7
    80004fbc:	855a                	mv	a0,s6
    80004fbe:	ffffc097          	auipc	ra,0xffffc
    80004fc2:	0f8080e7          	jalr	248(ra) # 800010b6 <walkaddr>
    80004fc6:	862a                	mv	a2,a0
    if(pa == 0)
    80004fc8:	dd4d                	beqz	a0,80004f82 <exec+0xe6>
    if(sz - i < PGSIZE)
    80004fca:	412984bb          	subw	s1,s3,s2
    80004fce:	0004879b          	sext.w	a5,s1
    80004fd2:	fcfcf0e3          	bgeu	s9,a5,80004f92 <exec+0xf6>
    80004fd6:	84d6                	mv	s1,s5
    80004fd8:	bf6d                	j	80004f92 <exec+0xf6>
    sz = sz1;
    80004fda:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fde:	2d85                	addw	s11,s11,1
    80004fe0:	038d0d1b          	addw	s10,s10,56
    80004fe4:	e8845783          	lhu	a5,-376(s0)
    80004fe8:	08fdd663          	bge	s11,a5,80005074 <exec+0x1d8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004fec:	2d01                	sext.w	s10,s10
    80004fee:	03800713          	li	a4,56
    80004ff2:	86ea                	mv	a3,s10
    80004ff4:	e1840613          	add	a2,s0,-488
    80004ff8:	4581                	li	a1,0
    80004ffa:	8552                	mv	a0,s4
    80004ffc:	fffff097          	auipc	ra,0xfffff
    80005000:	bea080e7          	jalr	-1046(ra) # 80003be6 <readi>
    80005004:	03800793          	li	a5,56
    80005008:	20f51063          	bne	a0,a5,80005208 <exec+0x36c>
    if(ph.type != ELF_PROG_LOAD)
    8000500c:	e1842783          	lw	a5,-488(s0)
    80005010:	4705                	li	a4,1
    80005012:	fce796e3          	bne	a5,a4,80004fde <exec+0x142>
    if(ph.memsz < ph.filesz)
    80005016:	e4043483          	ld	s1,-448(s0)
    8000501a:	e3843783          	ld	a5,-456(s0)
    8000501e:	1ef4e963          	bltu	s1,a5,80005210 <exec+0x374>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005022:	e2843783          	ld	a5,-472(s0)
    80005026:	94be                	add	s1,s1,a5
    80005028:	1ef4e863          	bltu	s1,a5,80005218 <exec+0x37c>
    if(ph.vaddr % PGSIZE != 0)
    8000502c:	df043703          	ld	a4,-528(s0)
    80005030:	8ff9                	and	a5,a5,a4
    80005032:	1e079763          	bnez	a5,80005220 <exec+0x384>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005036:	e1c42503          	lw	a0,-484(s0)
    8000503a:	00000097          	auipc	ra,0x0
    8000503e:	e48080e7          	jalr	-440(ra) # 80004e82 <flags2perm>
    80005042:	86aa                	mv	a3,a0
    80005044:	8626                	mv	a2,s1
    80005046:	85ca                	mv	a1,s2
    80005048:	855a                	mv	a0,s6
    8000504a:	ffffc097          	auipc	ra,0xffffc
    8000504e:	430080e7          	jalr	1072(ra) # 8000147a <uvmalloc>
    80005052:	e0a43423          	sd	a0,-504(s0)
    80005056:	1c050963          	beqz	a0,80005228 <exec+0x38c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000505a:	e2843b83          	ld	s7,-472(s0)
    8000505e:	e2042c03          	lw	s8,-480(s0)
    80005062:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005066:	00098463          	beqz	s3,8000506e <exec+0x1d2>
    8000506a:	4901                	li	s2,0
    8000506c:	b7a1                	j	80004fb4 <exec+0x118>
    sz = sz1;
    8000506e:	e0843903          	ld	s2,-504(s0)
    80005072:	b7b5                	j	80004fde <exec+0x142>
    80005074:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80005076:	8552                	mv	a0,s4
    80005078:	fffff097          	auipc	ra,0xfffff
    8000507c:	b1c080e7          	jalr	-1252(ra) # 80003b94 <iunlockput>
  end_op();
    80005080:	fffff097          	auipc	ra,0xfffff
    80005084:	2f6080e7          	jalr	758(ra) # 80004376 <end_op>
  p = myproc();
    80005088:	ffffd097          	auipc	ra,0xffffd
    8000508c:	9c2080e7          	jalr	-1598(ra) # 80001a4a <myproc>
    80005090:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005092:	06053c83          	ld	s9,96(a0)
  sz = PGROUNDUP(sz);
    80005096:	6985                	lui	s3,0x1
    80005098:	19fd                	add	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000509a:	99ca                	add	s3,s3,s2
    8000509c:	77fd                	lui	a5,0xfffff
    8000509e:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800050a2:	4691                	li	a3,4
    800050a4:	6609                	lui	a2,0x2
    800050a6:	964e                	add	a2,a2,s3
    800050a8:	85ce                	mv	a1,s3
    800050aa:	855a                	mv	a0,s6
    800050ac:	ffffc097          	auipc	ra,0xffffc
    800050b0:	3ce080e7          	jalr	974(ra) # 8000147a <uvmalloc>
    800050b4:	892a                	mv	s2,a0
    800050b6:	e0a43423          	sd	a0,-504(s0)
    800050ba:	e519                	bnez	a0,800050c8 <exec+0x22c>
  if(pagetable)
    800050bc:	e1343423          	sd	s3,-504(s0)
    800050c0:	4a01                	li	s4,0
    800050c2:	aaa5                	j	8000523a <exec+0x39e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800050c4:	4901                	li	s2,0
    800050c6:	bf45                	j	80005076 <exec+0x1da>
  uvmclear(pagetable, sz-2*PGSIZE);
    800050c8:	75f9                	lui	a1,0xffffe
    800050ca:	95aa                	add	a1,a1,a0
    800050cc:	855a                	mv	a0,s6
    800050ce:	ffffc097          	auipc	ra,0xffffc
    800050d2:	5e2080e7          	jalr	1506(ra) # 800016b0 <uvmclear>
  stackbase = sp - PGSIZE;
    800050d6:	7bfd                	lui	s7,0xfffff
    800050d8:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800050da:	e0043783          	ld	a5,-512(s0)
    800050de:	6388                	ld	a0,0(a5)
    800050e0:	c52d                	beqz	a0,8000514a <exec+0x2ae>
    800050e2:	e9040993          	add	s3,s0,-368
    800050e6:	f9040c13          	add	s8,s0,-112
    800050ea:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800050ec:	ffffc097          	auipc	ra,0xffffc
    800050f0:	dbc080e7          	jalr	-580(ra) # 80000ea8 <strlen>
    800050f4:	0015079b          	addw	a5,a0,1
    800050f8:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800050fc:	ff07f913          	and	s2,a5,-16
    if(sp < stackbase)
    80005100:	13796863          	bltu	s2,s7,80005230 <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005104:	e0043d03          	ld	s10,-512(s0)
    80005108:	000d3a03          	ld	s4,0(s10)
    8000510c:	8552                	mv	a0,s4
    8000510e:	ffffc097          	auipc	ra,0xffffc
    80005112:	d9a080e7          	jalr	-614(ra) # 80000ea8 <strlen>
    80005116:	0015069b          	addw	a3,a0,1
    8000511a:	8652                	mv	a2,s4
    8000511c:	85ca                	mv	a1,s2
    8000511e:	855a                	mv	a0,s6
    80005120:	ffffc097          	auipc	ra,0xffffc
    80005124:	5c2080e7          	jalr	1474(ra) # 800016e2 <copyout>
    80005128:	10054663          	bltz	a0,80005234 <exec+0x398>
    ustack[argc] = sp;
    8000512c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005130:	0485                	add	s1,s1,1
    80005132:	008d0793          	add	a5,s10,8
    80005136:	e0f43023          	sd	a5,-512(s0)
    8000513a:	008d3503          	ld	a0,8(s10)
    8000513e:	c909                	beqz	a0,80005150 <exec+0x2b4>
    if(argc >= MAXARG)
    80005140:	09a1                	add	s3,s3,8
    80005142:	fb8995e3          	bne	s3,s8,800050ec <exec+0x250>
  ip = 0;
    80005146:	4a01                	li	s4,0
    80005148:	a8cd                	j	8000523a <exec+0x39e>
  sp = sz;
    8000514a:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    8000514e:	4481                	li	s1,0
  ustack[argc] = 0;
    80005150:	00349793          	sll	a5,s1,0x3
    80005154:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffda2a0>
    80005158:	97a2                	add	a5,a5,s0
    8000515a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000515e:	00148693          	add	a3,s1,1
    80005162:	068e                	sll	a3,a3,0x3
    80005164:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005168:	ff097913          	and	s2,s2,-16
  sz = sz1;
    8000516c:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80005170:	f57966e3          	bltu	s2,s7,800050bc <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005174:	e9040613          	add	a2,s0,-368
    80005178:	85ca                	mv	a1,s2
    8000517a:	855a                	mv	a0,s6
    8000517c:	ffffc097          	auipc	ra,0xffffc
    80005180:	566080e7          	jalr	1382(ra) # 800016e2 <copyout>
    80005184:	0e054863          	bltz	a0,80005274 <exec+0x3d8>
  p->trapframe->a1 = sp;
    80005188:	070ab783          	ld	a5,112(s5) # 1070 <_entry-0x7fffef90>
    8000518c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005190:	df843783          	ld	a5,-520(s0)
    80005194:	0007c703          	lbu	a4,0(a5)
    80005198:	cf11                	beqz	a4,800051b4 <exec+0x318>
    8000519a:	0785                	add	a5,a5,1
    if(*s == '/')
    8000519c:	02f00693          	li	a3,47
    800051a0:	a039                	j	800051ae <exec+0x312>
      last = s+1;
    800051a2:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800051a6:	0785                	add	a5,a5,1
    800051a8:	fff7c703          	lbu	a4,-1(a5)
    800051ac:	c701                	beqz	a4,800051b4 <exec+0x318>
    if(*s == '/')
    800051ae:	fed71ce3          	bne	a4,a3,800051a6 <exec+0x30a>
    800051b2:	bfc5                	j	800051a2 <exec+0x306>
  safestrcpy(p->name, last, sizeof(p->name));
    800051b4:	4641                	li	a2,16
    800051b6:	df843583          	ld	a1,-520(s0)
    800051ba:	170a8513          	add	a0,s5,368
    800051be:	ffffc097          	auipc	ra,0xffffc
    800051c2:	cb8080e7          	jalr	-840(ra) # 80000e76 <safestrcpy>
  oldpagetable = p->pagetable;
    800051c6:	068ab503          	ld	a0,104(s5)
  p->pagetable = pagetable;
    800051ca:	076ab423          	sd	s6,104(s5)
  p->sz = sz;
    800051ce:	e0843783          	ld	a5,-504(s0)
    800051d2:	06fab023          	sd	a5,96(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800051d6:	070ab783          	ld	a5,112(s5)
    800051da:	e6843703          	ld	a4,-408(s0)
    800051de:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800051e0:	070ab783          	ld	a5,112(s5)
    800051e4:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800051e8:	85e6                	mv	a1,s9
    800051ea:	ffffd097          	auipc	ra,0xffffd
    800051ee:	9c0080e7          	jalr	-1600(ra) # 80001baa <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800051f2:	0004851b          	sext.w	a0,s1
    800051f6:	79be                	ld	s3,488(sp)
    800051f8:	7a1e                	ld	s4,480(sp)
    800051fa:	6afe                	ld	s5,472(sp)
    800051fc:	6b5e                	ld	s6,464(sp)
    800051fe:	6bbe                	ld	s7,456(sp)
    80005200:	6c1e                	ld	s8,448(sp)
    80005202:	7cfa                	ld	s9,440(sp)
    80005204:	7d5a                	ld	s10,432(sp)
    80005206:	b305                	j	80004f26 <exec+0x8a>
    80005208:	e1243423          	sd	s2,-504(s0)
    8000520c:	7dba                	ld	s11,424(sp)
    8000520e:	a035                	j	8000523a <exec+0x39e>
    80005210:	e1243423          	sd	s2,-504(s0)
    80005214:	7dba                	ld	s11,424(sp)
    80005216:	a015                	j	8000523a <exec+0x39e>
    80005218:	e1243423          	sd	s2,-504(s0)
    8000521c:	7dba                	ld	s11,424(sp)
    8000521e:	a831                	j	8000523a <exec+0x39e>
    80005220:	e1243423          	sd	s2,-504(s0)
    80005224:	7dba                	ld	s11,424(sp)
    80005226:	a811                	j	8000523a <exec+0x39e>
    80005228:	e1243423          	sd	s2,-504(s0)
    8000522c:	7dba                	ld	s11,424(sp)
    8000522e:	a031                	j	8000523a <exec+0x39e>
  ip = 0;
    80005230:	4a01                	li	s4,0
    80005232:	a021                	j	8000523a <exec+0x39e>
    80005234:	4a01                	li	s4,0
  if(pagetable)
    80005236:	a011                	j	8000523a <exec+0x39e>
    80005238:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    8000523a:	e0843583          	ld	a1,-504(s0)
    8000523e:	855a                	mv	a0,s6
    80005240:	ffffd097          	auipc	ra,0xffffd
    80005244:	96a080e7          	jalr	-1686(ra) # 80001baa <proc_freepagetable>
  return -1;
    80005248:	557d                	li	a0,-1
  if(ip){
    8000524a:	000a1b63          	bnez	s4,80005260 <exec+0x3c4>
    8000524e:	79be                	ld	s3,488(sp)
    80005250:	7a1e                	ld	s4,480(sp)
    80005252:	6afe                	ld	s5,472(sp)
    80005254:	6b5e                	ld	s6,464(sp)
    80005256:	6bbe                	ld	s7,456(sp)
    80005258:	6c1e                	ld	s8,448(sp)
    8000525a:	7cfa                	ld	s9,440(sp)
    8000525c:	7d5a                	ld	s10,432(sp)
    8000525e:	b1e1                	j	80004f26 <exec+0x8a>
    80005260:	79be                	ld	s3,488(sp)
    80005262:	6afe                	ld	s5,472(sp)
    80005264:	6b5e                	ld	s6,464(sp)
    80005266:	6bbe                	ld	s7,456(sp)
    80005268:	6c1e                	ld	s8,448(sp)
    8000526a:	7cfa                	ld	s9,440(sp)
    8000526c:	7d5a                	ld	s10,432(sp)
    8000526e:	b14d                	j	80004f10 <exec+0x74>
    80005270:	6b5e                	ld	s6,464(sp)
    80005272:	b979                	j	80004f10 <exec+0x74>
  sz = sz1;
    80005274:	e0843983          	ld	s3,-504(s0)
    80005278:	b591                	j	800050bc <exec+0x220>

000000008000527a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000527a:	7179                	add	sp,sp,-48
    8000527c:	f406                	sd	ra,40(sp)
    8000527e:	f022                	sd	s0,32(sp)
    80005280:	ec26                	sd	s1,24(sp)
    80005282:	e84a                	sd	s2,16(sp)
    80005284:	1800                	add	s0,sp,48
    80005286:	892e                	mv	s2,a1
    80005288:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000528a:	fdc40593          	add	a1,s0,-36
    8000528e:	ffffe097          	auipc	ra,0xffffe
    80005292:	902080e7          	jalr	-1790(ra) # 80002b90 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005296:	fdc42703          	lw	a4,-36(s0)
    8000529a:	47bd                	li	a5,15
    8000529c:	02e7eb63          	bltu	a5,a4,800052d2 <argfd+0x58>
    800052a0:	ffffc097          	auipc	ra,0xffffc
    800052a4:	7aa080e7          	jalr	1962(ra) # 80001a4a <myproc>
    800052a8:	fdc42703          	lw	a4,-36(s0)
    800052ac:	01c70793          	add	a5,a4,28
    800052b0:	078e                	sll	a5,a5,0x3
    800052b2:	953e                	add	a0,a0,a5
    800052b4:	651c                	ld	a5,8(a0)
    800052b6:	c385                	beqz	a5,800052d6 <argfd+0x5c>
    return -1;
  if(pfd)
    800052b8:	00090463          	beqz	s2,800052c0 <argfd+0x46>
    *pfd = fd;
    800052bc:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800052c0:	4501                	li	a0,0
  if(pf)
    800052c2:	c091                	beqz	s1,800052c6 <argfd+0x4c>
    *pf = f;
    800052c4:	e09c                	sd	a5,0(s1)
}
    800052c6:	70a2                	ld	ra,40(sp)
    800052c8:	7402                	ld	s0,32(sp)
    800052ca:	64e2                	ld	s1,24(sp)
    800052cc:	6942                	ld	s2,16(sp)
    800052ce:	6145                	add	sp,sp,48
    800052d0:	8082                	ret
    return -1;
    800052d2:	557d                	li	a0,-1
    800052d4:	bfcd                	j	800052c6 <argfd+0x4c>
    800052d6:	557d                	li	a0,-1
    800052d8:	b7fd                	j	800052c6 <argfd+0x4c>

00000000800052da <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800052da:	1101                	add	sp,sp,-32
    800052dc:	ec06                	sd	ra,24(sp)
    800052de:	e822                	sd	s0,16(sp)
    800052e0:	e426                	sd	s1,8(sp)
    800052e2:	1000                	add	s0,sp,32
    800052e4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800052e6:	ffffc097          	auipc	ra,0xffffc
    800052ea:	764080e7          	jalr	1892(ra) # 80001a4a <myproc>
    800052ee:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800052f0:	0e850793          	add	a5,a0,232
    800052f4:	4501                	li	a0,0
    800052f6:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800052f8:	6398                	ld	a4,0(a5)
    800052fa:	cb19                	beqz	a4,80005310 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800052fc:	2505                	addw	a0,a0,1
    800052fe:	07a1                	add	a5,a5,8
    80005300:	fed51ce3          	bne	a0,a3,800052f8 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005304:	557d                	li	a0,-1
}
    80005306:	60e2                	ld	ra,24(sp)
    80005308:	6442                	ld	s0,16(sp)
    8000530a:	64a2                	ld	s1,8(sp)
    8000530c:	6105                	add	sp,sp,32
    8000530e:	8082                	ret
      p->ofile[fd] = f;
    80005310:	01c50793          	add	a5,a0,28
    80005314:	078e                	sll	a5,a5,0x3
    80005316:	963e                	add	a2,a2,a5
    80005318:	e604                	sd	s1,8(a2)
      return fd;
    8000531a:	b7f5                	j	80005306 <fdalloc+0x2c>

000000008000531c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000531c:	715d                	add	sp,sp,-80
    8000531e:	e486                	sd	ra,72(sp)
    80005320:	e0a2                	sd	s0,64(sp)
    80005322:	fc26                	sd	s1,56(sp)
    80005324:	f84a                	sd	s2,48(sp)
    80005326:	f44e                	sd	s3,40(sp)
    80005328:	ec56                	sd	s5,24(sp)
    8000532a:	e85a                	sd	s6,16(sp)
    8000532c:	0880                	add	s0,sp,80
    8000532e:	8b2e                	mv	s6,a1
    80005330:	89b2                	mv	s3,a2
    80005332:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005334:	fb040593          	add	a1,s0,-80
    80005338:	fffff097          	auipc	ra,0xfffff
    8000533c:	de2080e7          	jalr	-542(ra) # 8000411a <nameiparent>
    80005340:	84aa                	mv	s1,a0
    80005342:	14050e63          	beqz	a0,8000549e <create+0x182>
    return 0;

  ilock(dp);
    80005346:	ffffe097          	auipc	ra,0xffffe
    8000534a:	5e8080e7          	jalr	1512(ra) # 8000392e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000534e:	4601                	li	a2,0
    80005350:	fb040593          	add	a1,s0,-80
    80005354:	8526                	mv	a0,s1
    80005356:	fffff097          	auipc	ra,0xfffff
    8000535a:	ae4080e7          	jalr	-1308(ra) # 80003e3a <dirlookup>
    8000535e:	8aaa                	mv	s5,a0
    80005360:	c539                	beqz	a0,800053ae <create+0x92>
    iunlockput(dp);
    80005362:	8526                	mv	a0,s1
    80005364:	fffff097          	auipc	ra,0xfffff
    80005368:	830080e7          	jalr	-2000(ra) # 80003b94 <iunlockput>
    ilock(ip);
    8000536c:	8556                	mv	a0,s5
    8000536e:	ffffe097          	auipc	ra,0xffffe
    80005372:	5c0080e7          	jalr	1472(ra) # 8000392e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005376:	4789                	li	a5,2
    80005378:	02fb1463          	bne	s6,a5,800053a0 <create+0x84>
    8000537c:	044ad783          	lhu	a5,68(s5)
    80005380:	37f9                	addw	a5,a5,-2
    80005382:	17c2                	sll	a5,a5,0x30
    80005384:	93c1                	srl	a5,a5,0x30
    80005386:	4705                	li	a4,1
    80005388:	00f76c63          	bltu	a4,a5,800053a0 <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000538c:	8556                	mv	a0,s5
    8000538e:	60a6                	ld	ra,72(sp)
    80005390:	6406                	ld	s0,64(sp)
    80005392:	74e2                	ld	s1,56(sp)
    80005394:	7942                	ld	s2,48(sp)
    80005396:	79a2                	ld	s3,40(sp)
    80005398:	6ae2                	ld	s5,24(sp)
    8000539a:	6b42                	ld	s6,16(sp)
    8000539c:	6161                	add	sp,sp,80
    8000539e:	8082                	ret
    iunlockput(ip);
    800053a0:	8556                	mv	a0,s5
    800053a2:	ffffe097          	auipc	ra,0xffffe
    800053a6:	7f2080e7          	jalr	2034(ra) # 80003b94 <iunlockput>
    return 0;
    800053aa:	4a81                	li	s5,0
    800053ac:	b7c5                	j	8000538c <create+0x70>
    800053ae:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    800053b0:	85da                	mv	a1,s6
    800053b2:	4088                	lw	a0,0(s1)
    800053b4:	ffffe097          	auipc	ra,0xffffe
    800053b8:	3d6080e7          	jalr	982(ra) # 8000378a <ialloc>
    800053bc:	8a2a                	mv	s4,a0
    800053be:	c531                	beqz	a0,8000540a <create+0xee>
  ilock(ip);
    800053c0:	ffffe097          	auipc	ra,0xffffe
    800053c4:	56e080e7          	jalr	1390(ra) # 8000392e <ilock>
  ip->major = major;
    800053c8:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800053cc:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800053d0:	4905                	li	s2,1
    800053d2:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800053d6:	8552                	mv	a0,s4
    800053d8:	ffffe097          	auipc	ra,0xffffe
    800053dc:	48a080e7          	jalr	1162(ra) # 80003862 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800053e0:	032b0d63          	beq	s6,s2,8000541a <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800053e4:	004a2603          	lw	a2,4(s4)
    800053e8:	fb040593          	add	a1,s0,-80
    800053ec:	8526                	mv	a0,s1
    800053ee:	fffff097          	auipc	ra,0xfffff
    800053f2:	c5c080e7          	jalr	-932(ra) # 8000404a <dirlink>
    800053f6:	08054163          	bltz	a0,80005478 <create+0x15c>
  iunlockput(dp);
    800053fa:	8526                	mv	a0,s1
    800053fc:	ffffe097          	auipc	ra,0xffffe
    80005400:	798080e7          	jalr	1944(ra) # 80003b94 <iunlockput>
  return ip;
    80005404:	8ad2                	mv	s5,s4
    80005406:	7a02                	ld	s4,32(sp)
    80005408:	b751                	j	8000538c <create+0x70>
    iunlockput(dp);
    8000540a:	8526                	mv	a0,s1
    8000540c:	ffffe097          	auipc	ra,0xffffe
    80005410:	788080e7          	jalr	1928(ra) # 80003b94 <iunlockput>
    return 0;
    80005414:	8ad2                	mv	s5,s4
    80005416:	7a02                	ld	s4,32(sp)
    80005418:	bf95                	j	8000538c <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000541a:	004a2603          	lw	a2,4(s4)
    8000541e:	00003597          	auipc	a1,0x3
    80005422:	30a58593          	add	a1,a1,778 # 80008728 <states.0+0x220>
    80005426:	8552                	mv	a0,s4
    80005428:	fffff097          	auipc	ra,0xfffff
    8000542c:	c22080e7          	jalr	-990(ra) # 8000404a <dirlink>
    80005430:	04054463          	bltz	a0,80005478 <create+0x15c>
    80005434:	40d0                	lw	a2,4(s1)
    80005436:	00003597          	auipc	a1,0x3
    8000543a:	2fa58593          	add	a1,a1,762 # 80008730 <states.0+0x228>
    8000543e:	8552                	mv	a0,s4
    80005440:	fffff097          	auipc	ra,0xfffff
    80005444:	c0a080e7          	jalr	-1014(ra) # 8000404a <dirlink>
    80005448:	02054863          	bltz	a0,80005478 <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    8000544c:	004a2603          	lw	a2,4(s4)
    80005450:	fb040593          	add	a1,s0,-80
    80005454:	8526                	mv	a0,s1
    80005456:	fffff097          	auipc	ra,0xfffff
    8000545a:	bf4080e7          	jalr	-1036(ra) # 8000404a <dirlink>
    8000545e:	00054d63          	bltz	a0,80005478 <create+0x15c>
    dp->nlink++;  // for ".."
    80005462:	04a4d783          	lhu	a5,74(s1)
    80005466:	2785                	addw	a5,a5,1
    80005468:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000546c:	8526                	mv	a0,s1
    8000546e:	ffffe097          	auipc	ra,0xffffe
    80005472:	3f4080e7          	jalr	1012(ra) # 80003862 <iupdate>
    80005476:	b751                	j	800053fa <create+0xde>
  ip->nlink = 0;
    80005478:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000547c:	8552                	mv	a0,s4
    8000547e:	ffffe097          	auipc	ra,0xffffe
    80005482:	3e4080e7          	jalr	996(ra) # 80003862 <iupdate>
  iunlockput(ip);
    80005486:	8552                	mv	a0,s4
    80005488:	ffffe097          	auipc	ra,0xffffe
    8000548c:	70c080e7          	jalr	1804(ra) # 80003b94 <iunlockput>
  iunlockput(dp);
    80005490:	8526                	mv	a0,s1
    80005492:	ffffe097          	auipc	ra,0xffffe
    80005496:	702080e7          	jalr	1794(ra) # 80003b94 <iunlockput>
  return 0;
    8000549a:	7a02                	ld	s4,32(sp)
    8000549c:	bdc5                	j	8000538c <create+0x70>
    return 0;
    8000549e:	8aaa                	mv	s5,a0
    800054a0:	b5f5                	j	8000538c <create+0x70>

00000000800054a2 <sys_dup>:
{
    800054a2:	7179                	add	sp,sp,-48
    800054a4:	f406                	sd	ra,40(sp)
    800054a6:	f022                	sd	s0,32(sp)
    800054a8:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800054aa:	fd840613          	add	a2,s0,-40
    800054ae:	4581                	li	a1,0
    800054b0:	4501                	li	a0,0
    800054b2:	00000097          	auipc	ra,0x0
    800054b6:	dc8080e7          	jalr	-568(ra) # 8000527a <argfd>
    return -1;
    800054ba:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800054bc:	02054763          	bltz	a0,800054ea <sys_dup+0x48>
    800054c0:	ec26                	sd	s1,24(sp)
    800054c2:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800054c4:	fd843903          	ld	s2,-40(s0)
    800054c8:	854a                	mv	a0,s2
    800054ca:	00000097          	auipc	ra,0x0
    800054ce:	e10080e7          	jalr	-496(ra) # 800052da <fdalloc>
    800054d2:	84aa                	mv	s1,a0
    return -1;
    800054d4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800054d6:	00054f63          	bltz	a0,800054f4 <sys_dup+0x52>
  filedup(f);
    800054da:	854a                	mv	a0,s2
    800054dc:	fffff097          	auipc	ra,0xfffff
    800054e0:	298080e7          	jalr	664(ra) # 80004774 <filedup>
  return fd;
    800054e4:	87a6                	mv	a5,s1
    800054e6:	64e2                	ld	s1,24(sp)
    800054e8:	6942                	ld	s2,16(sp)
}
    800054ea:	853e                	mv	a0,a5
    800054ec:	70a2                	ld	ra,40(sp)
    800054ee:	7402                	ld	s0,32(sp)
    800054f0:	6145                	add	sp,sp,48
    800054f2:	8082                	ret
    800054f4:	64e2                	ld	s1,24(sp)
    800054f6:	6942                	ld	s2,16(sp)
    800054f8:	bfcd                	j	800054ea <sys_dup+0x48>

00000000800054fa <sys_read>:
{
    800054fa:	7179                	add	sp,sp,-48
    800054fc:	f406                	sd	ra,40(sp)
    800054fe:	f022                	sd	s0,32(sp)
    80005500:	1800                	add	s0,sp,48
  argaddr(1, &p);
    80005502:	fd840593          	add	a1,s0,-40
    80005506:	4505                	li	a0,1
    80005508:	ffffd097          	auipc	ra,0xffffd
    8000550c:	6a8080e7          	jalr	1704(ra) # 80002bb0 <argaddr>
  argint(2, &n);
    80005510:	fe440593          	add	a1,s0,-28
    80005514:	4509                	li	a0,2
    80005516:	ffffd097          	auipc	ra,0xffffd
    8000551a:	67a080e7          	jalr	1658(ra) # 80002b90 <argint>
  if(argfd(0, 0, &f) < 0)
    8000551e:	fe840613          	add	a2,s0,-24
    80005522:	4581                	li	a1,0
    80005524:	4501                	li	a0,0
    80005526:	00000097          	auipc	ra,0x0
    8000552a:	d54080e7          	jalr	-684(ra) # 8000527a <argfd>
    8000552e:	87aa                	mv	a5,a0
    return -1;
    80005530:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005532:	0007cc63          	bltz	a5,8000554a <sys_read+0x50>
  return fileread(f, p, n);
    80005536:	fe442603          	lw	a2,-28(s0)
    8000553a:	fd843583          	ld	a1,-40(s0)
    8000553e:	fe843503          	ld	a0,-24(s0)
    80005542:	fffff097          	auipc	ra,0xfffff
    80005546:	3d8080e7          	jalr	984(ra) # 8000491a <fileread>
}
    8000554a:	70a2                	ld	ra,40(sp)
    8000554c:	7402                	ld	s0,32(sp)
    8000554e:	6145                	add	sp,sp,48
    80005550:	8082                	ret

0000000080005552 <sys_write>:
{
    80005552:	7179                	add	sp,sp,-48
    80005554:	f406                	sd	ra,40(sp)
    80005556:	f022                	sd	s0,32(sp)
    80005558:	1800                	add	s0,sp,48
  argaddr(1, &p);
    8000555a:	fd840593          	add	a1,s0,-40
    8000555e:	4505                	li	a0,1
    80005560:	ffffd097          	auipc	ra,0xffffd
    80005564:	650080e7          	jalr	1616(ra) # 80002bb0 <argaddr>
  argint(2, &n);
    80005568:	fe440593          	add	a1,s0,-28
    8000556c:	4509                	li	a0,2
    8000556e:	ffffd097          	auipc	ra,0xffffd
    80005572:	622080e7          	jalr	1570(ra) # 80002b90 <argint>
  if(argfd(0, 0, &f) < 0)
    80005576:	fe840613          	add	a2,s0,-24
    8000557a:	4581                	li	a1,0
    8000557c:	4501                	li	a0,0
    8000557e:	00000097          	auipc	ra,0x0
    80005582:	cfc080e7          	jalr	-772(ra) # 8000527a <argfd>
    80005586:	87aa                	mv	a5,a0
    return -1;
    80005588:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000558a:	0007cc63          	bltz	a5,800055a2 <sys_write+0x50>
  return filewrite(f, p, n);
    8000558e:	fe442603          	lw	a2,-28(s0)
    80005592:	fd843583          	ld	a1,-40(s0)
    80005596:	fe843503          	ld	a0,-24(s0)
    8000559a:	fffff097          	auipc	ra,0xfffff
    8000559e:	452080e7          	jalr	1106(ra) # 800049ec <filewrite>
}
    800055a2:	70a2                	ld	ra,40(sp)
    800055a4:	7402                	ld	s0,32(sp)
    800055a6:	6145                	add	sp,sp,48
    800055a8:	8082                	ret

00000000800055aa <sys_close>:
{
    800055aa:	1101                	add	sp,sp,-32
    800055ac:	ec06                	sd	ra,24(sp)
    800055ae:	e822                	sd	s0,16(sp)
    800055b0:	1000                	add	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800055b2:	fe040613          	add	a2,s0,-32
    800055b6:	fec40593          	add	a1,s0,-20
    800055ba:	4501                	li	a0,0
    800055bc:	00000097          	auipc	ra,0x0
    800055c0:	cbe080e7          	jalr	-834(ra) # 8000527a <argfd>
    return -1;
    800055c4:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800055c6:	02054463          	bltz	a0,800055ee <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800055ca:	ffffc097          	auipc	ra,0xffffc
    800055ce:	480080e7          	jalr	1152(ra) # 80001a4a <myproc>
    800055d2:	fec42783          	lw	a5,-20(s0)
    800055d6:	07f1                	add	a5,a5,28
    800055d8:	078e                	sll	a5,a5,0x3
    800055da:	953e                	add	a0,a0,a5
    800055dc:	00053423          	sd	zero,8(a0)
  fileclose(f);
    800055e0:	fe043503          	ld	a0,-32(s0)
    800055e4:	fffff097          	auipc	ra,0xfffff
    800055e8:	1e2080e7          	jalr	482(ra) # 800047c6 <fileclose>
  return 0;
    800055ec:	4781                	li	a5,0
}
    800055ee:	853e                	mv	a0,a5
    800055f0:	60e2                	ld	ra,24(sp)
    800055f2:	6442                	ld	s0,16(sp)
    800055f4:	6105                	add	sp,sp,32
    800055f6:	8082                	ret

00000000800055f8 <sys_fstat>:
{
    800055f8:	1101                	add	sp,sp,-32
    800055fa:	ec06                	sd	ra,24(sp)
    800055fc:	e822                	sd	s0,16(sp)
    800055fe:	1000                	add	s0,sp,32
  argaddr(1, &st);
    80005600:	fe040593          	add	a1,s0,-32
    80005604:	4505                	li	a0,1
    80005606:	ffffd097          	auipc	ra,0xffffd
    8000560a:	5aa080e7          	jalr	1450(ra) # 80002bb0 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000560e:	fe840613          	add	a2,s0,-24
    80005612:	4581                	li	a1,0
    80005614:	4501                	li	a0,0
    80005616:	00000097          	auipc	ra,0x0
    8000561a:	c64080e7          	jalr	-924(ra) # 8000527a <argfd>
    8000561e:	87aa                	mv	a5,a0
    return -1;
    80005620:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005622:	0007ca63          	bltz	a5,80005636 <sys_fstat+0x3e>
  return filestat(f, st);
    80005626:	fe043583          	ld	a1,-32(s0)
    8000562a:	fe843503          	ld	a0,-24(s0)
    8000562e:	fffff097          	auipc	ra,0xfffff
    80005632:	27a080e7          	jalr	634(ra) # 800048a8 <filestat>
}
    80005636:	60e2                	ld	ra,24(sp)
    80005638:	6442                	ld	s0,16(sp)
    8000563a:	6105                	add	sp,sp,32
    8000563c:	8082                	ret

000000008000563e <sys_link>:
{
    8000563e:	7169                	add	sp,sp,-304
    80005640:	f606                	sd	ra,296(sp)
    80005642:	f222                	sd	s0,288(sp)
    80005644:	1a00                	add	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005646:	08000613          	li	a2,128
    8000564a:	ed040593          	add	a1,s0,-304
    8000564e:	4501                	li	a0,0
    80005650:	ffffd097          	auipc	ra,0xffffd
    80005654:	580080e7          	jalr	1408(ra) # 80002bd0 <argstr>
    return -1;
    80005658:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000565a:	12054663          	bltz	a0,80005786 <sys_link+0x148>
    8000565e:	08000613          	li	a2,128
    80005662:	f5040593          	add	a1,s0,-176
    80005666:	4505                	li	a0,1
    80005668:	ffffd097          	auipc	ra,0xffffd
    8000566c:	568080e7          	jalr	1384(ra) # 80002bd0 <argstr>
    return -1;
    80005670:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005672:	10054a63          	bltz	a0,80005786 <sys_link+0x148>
    80005676:	ee26                	sd	s1,280(sp)
  begin_op();
    80005678:	fffff097          	auipc	ra,0xfffff
    8000567c:	c84080e7          	jalr	-892(ra) # 800042fc <begin_op>
  if((ip = namei(old)) == 0){
    80005680:	ed040513          	add	a0,s0,-304
    80005684:	fffff097          	auipc	ra,0xfffff
    80005688:	a78080e7          	jalr	-1416(ra) # 800040fc <namei>
    8000568c:	84aa                	mv	s1,a0
    8000568e:	c949                	beqz	a0,80005720 <sys_link+0xe2>
  ilock(ip);
    80005690:	ffffe097          	auipc	ra,0xffffe
    80005694:	29e080e7          	jalr	670(ra) # 8000392e <ilock>
  if(ip->type == T_DIR){
    80005698:	04449703          	lh	a4,68(s1)
    8000569c:	4785                	li	a5,1
    8000569e:	08f70863          	beq	a4,a5,8000572e <sys_link+0xf0>
    800056a2:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800056a4:	04a4d783          	lhu	a5,74(s1)
    800056a8:	2785                	addw	a5,a5,1
    800056aa:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056ae:	8526                	mv	a0,s1
    800056b0:	ffffe097          	auipc	ra,0xffffe
    800056b4:	1b2080e7          	jalr	434(ra) # 80003862 <iupdate>
  iunlock(ip);
    800056b8:	8526                	mv	a0,s1
    800056ba:	ffffe097          	auipc	ra,0xffffe
    800056be:	33a080e7          	jalr	826(ra) # 800039f4 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800056c2:	fd040593          	add	a1,s0,-48
    800056c6:	f5040513          	add	a0,s0,-176
    800056ca:	fffff097          	auipc	ra,0xfffff
    800056ce:	a50080e7          	jalr	-1456(ra) # 8000411a <nameiparent>
    800056d2:	892a                	mv	s2,a0
    800056d4:	cd35                	beqz	a0,80005750 <sys_link+0x112>
  ilock(dp);
    800056d6:	ffffe097          	auipc	ra,0xffffe
    800056da:	258080e7          	jalr	600(ra) # 8000392e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800056de:	00092703          	lw	a4,0(s2)
    800056e2:	409c                	lw	a5,0(s1)
    800056e4:	06f71163          	bne	a4,a5,80005746 <sys_link+0x108>
    800056e8:	40d0                	lw	a2,4(s1)
    800056ea:	fd040593          	add	a1,s0,-48
    800056ee:	854a                	mv	a0,s2
    800056f0:	fffff097          	auipc	ra,0xfffff
    800056f4:	95a080e7          	jalr	-1702(ra) # 8000404a <dirlink>
    800056f8:	04054763          	bltz	a0,80005746 <sys_link+0x108>
  iunlockput(dp);
    800056fc:	854a                	mv	a0,s2
    800056fe:	ffffe097          	auipc	ra,0xffffe
    80005702:	496080e7          	jalr	1174(ra) # 80003b94 <iunlockput>
  iput(ip);
    80005706:	8526                	mv	a0,s1
    80005708:	ffffe097          	auipc	ra,0xffffe
    8000570c:	3e4080e7          	jalr	996(ra) # 80003aec <iput>
  end_op();
    80005710:	fffff097          	auipc	ra,0xfffff
    80005714:	c66080e7          	jalr	-922(ra) # 80004376 <end_op>
  return 0;
    80005718:	4781                	li	a5,0
    8000571a:	64f2                	ld	s1,280(sp)
    8000571c:	6952                	ld	s2,272(sp)
    8000571e:	a0a5                	j	80005786 <sys_link+0x148>
    end_op();
    80005720:	fffff097          	auipc	ra,0xfffff
    80005724:	c56080e7          	jalr	-938(ra) # 80004376 <end_op>
    return -1;
    80005728:	57fd                	li	a5,-1
    8000572a:	64f2                	ld	s1,280(sp)
    8000572c:	a8a9                	j	80005786 <sys_link+0x148>
    iunlockput(ip);
    8000572e:	8526                	mv	a0,s1
    80005730:	ffffe097          	auipc	ra,0xffffe
    80005734:	464080e7          	jalr	1124(ra) # 80003b94 <iunlockput>
    end_op();
    80005738:	fffff097          	auipc	ra,0xfffff
    8000573c:	c3e080e7          	jalr	-962(ra) # 80004376 <end_op>
    return -1;
    80005740:	57fd                	li	a5,-1
    80005742:	64f2                	ld	s1,280(sp)
    80005744:	a089                	j	80005786 <sys_link+0x148>
    iunlockput(dp);
    80005746:	854a                	mv	a0,s2
    80005748:	ffffe097          	auipc	ra,0xffffe
    8000574c:	44c080e7          	jalr	1100(ra) # 80003b94 <iunlockput>
  ilock(ip);
    80005750:	8526                	mv	a0,s1
    80005752:	ffffe097          	auipc	ra,0xffffe
    80005756:	1dc080e7          	jalr	476(ra) # 8000392e <ilock>
  ip->nlink--;
    8000575a:	04a4d783          	lhu	a5,74(s1)
    8000575e:	37fd                	addw	a5,a5,-1
    80005760:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005764:	8526                	mv	a0,s1
    80005766:	ffffe097          	auipc	ra,0xffffe
    8000576a:	0fc080e7          	jalr	252(ra) # 80003862 <iupdate>
  iunlockput(ip);
    8000576e:	8526                	mv	a0,s1
    80005770:	ffffe097          	auipc	ra,0xffffe
    80005774:	424080e7          	jalr	1060(ra) # 80003b94 <iunlockput>
  end_op();
    80005778:	fffff097          	auipc	ra,0xfffff
    8000577c:	bfe080e7          	jalr	-1026(ra) # 80004376 <end_op>
  return -1;
    80005780:	57fd                	li	a5,-1
    80005782:	64f2                	ld	s1,280(sp)
    80005784:	6952                	ld	s2,272(sp)
}
    80005786:	853e                	mv	a0,a5
    80005788:	70b2                	ld	ra,296(sp)
    8000578a:	7412                	ld	s0,288(sp)
    8000578c:	6155                	add	sp,sp,304
    8000578e:	8082                	ret

0000000080005790 <sys_unlink>:
{
    80005790:	7151                	add	sp,sp,-240
    80005792:	f586                	sd	ra,232(sp)
    80005794:	f1a2                	sd	s0,224(sp)
    80005796:	1980                	add	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005798:	08000613          	li	a2,128
    8000579c:	f3040593          	add	a1,s0,-208
    800057a0:	4501                	li	a0,0
    800057a2:	ffffd097          	auipc	ra,0xffffd
    800057a6:	42e080e7          	jalr	1070(ra) # 80002bd0 <argstr>
    800057aa:	1a054a63          	bltz	a0,8000595e <sys_unlink+0x1ce>
    800057ae:	eda6                	sd	s1,216(sp)
  begin_op();
    800057b0:	fffff097          	auipc	ra,0xfffff
    800057b4:	b4c080e7          	jalr	-1204(ra) # 800042fc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800057b8:	fb040593          	add	a1,s0,-80
    800057bc:	f3040513          	add	a0,s0,-208
    800057c0:	fffff097          	auipc	ra,0xfffff
    800057c4:	95a080e7          	jalr	-1702(ra) # 8000411a <nameiparent>
    800057c8:	84aa                	mv	s1,a0
    800057ca:	cd71                	beqz	a0,800058a6 <sys_unlink+0x116>
  ilock(dp);
    800057cc:	ffffe097          	auipc	ra,0xffffe
    800057d0:	162080e7          	jalr	354(ra) # 8000392e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800057d4:	00003597          	auipc	a1,0x3
    800057d8:	f5458593          	add	a1,a1,-172 # 80008728 <states.0+0x220>
    800057dc:	fb040513          	add	a0,s0,-80
    800057e0:	ffffe097          	auipc	ra,0xffffe
    800057e4:	640080e7          	jalr	1600(ra) # 80003e20 <namecmp>
    800057e8:	14050c63          	beqz	a0,80005940 <sys_unlink+0x1b0>
    800057ec:	00003597          	auipc	a1,0x3
    800057f0:	f4458593          	add	a1,a1,-188 # 80008730 <states.0+0x228>
    800057f4:	fb040513          	add	a0,s0,-80
    800057f8:	ffffe097          	auipc	ra,0xffffe
    800057fc:	628080e7          	jalr	1576(ra) # 80003e20 <namecmp>
    80005800:	14050063          	beqz	a0,80005940 <sys_unlink+0x1b0>
    80005804:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005806:	f2c40613          	add	a2,s0,-212
    8000580a:	fb040593          	add	a1,s0,-80
    8000580e:	8526                	mv	a0,s1
    80005810:	ffffe097          	auipc	ra,0xffffe
    80005814:	62a080e7          	jalr	1578(ra) # 80003e3a <dirlookup>
    80005818:	892a                	mv	s2,a0
    8000581a:	12050263          	beqz	a0,8000593e <sys_unlink+0x1ae>
  ilock(ip);
    8000581e:	ffffe097          	auipc	ra,0xffffe
    80005822:	110080e7          	jalr	272(ra) # 8000392e <ilock>
  if(ip->nlink < 1)
    80005826:	04a91783          	lh	a5,74(s2)
    8000582a:	08f05563          	blez	a5,800058b4 <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000582e:	04491703          	lh	a4,68(s2)
    80005832:	4785                	li	a5,1
    80005834:	08f70963          	beq	a4,a5,800058c6 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005838:	4641                	li	a2,16
    8000583a:	4581                	li	a1,0
    8000583c:	fc040513          	add	a0,s0,-64
    80005840:	ffffb097          	auipc	ra,0xffffb
    80005844:	4f4080e7          	jalr	1268(ra) # 80000d34 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005848:	4741                	li	a4,16
    8000584a:	f2c42683          	lw	a3,-212(s0)
    8000584e:	fc040613          	add	a2,s0,-64
    80005852:	4581                	li	a1,0
    80005854:	8526                	mv	a0,s1
    80005856:	ffffe097          	auipc	ra,0xffffe
    8000585a:	4a0080e7          	jalr	1184(ra) # 80003cf6 <writei>
    8000585e:	47c1                	li	a5,16
    80005860:	0af51b63          	bne	a0,a5,80005916 <sys_unlink+0x186>
  if(ip->type == T_DIR){
    80005864:	04491703          	lh	a4,68(s2)
    80005868:	4785                	li	a5,1
    8000586a:	0af70f63          	beq	a4,a5,80005928 <sys_unlink+0x198>
  iunlockput(dp);
    8000586e:	8526                	mv	a0,s1
    80005870:	ffffe097          	auipc	ra,0xffffe
    80005874:	324080e7          	jalr	804(ra) # 80003b94 <iunlockput>
  ip->nlink--;
    80005878:	04a95783          	lhu	a5,74(s2)
    8000587c:	37fd                	addw	a5,a5,-1
    8000587e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005882:	854a                	mv	a0,s2
    80005884:	ffffe097          	auipc	ra,0xffffe
    80005888:	fde080e7          	jalr	-34(ra) # 80003862 <iupdate>
  iunlockput(ip);
    8000588c:	854a                	mv	a0,s2
    8000588e:	ffffe097          	auipc	ra,0xffffe
    80005892:	306080e7          	jalr	774(ra) # 80003b94 <iunlockput>
  end_op();
    80005896:	fffff097          	auipc	ra,0xfffff
    8000589a:	ae0080e7          	jalr	-1312(ra) # 80004376 <end_op>
  return 0;
    8000589e:	4501                	li	a0,0
    800058a0:	64ee                	ld	s1,216(sp)
    800058a2:	694e                	ld	s2,208(sp)
    800058a4:	a84d                	j	80005956 <sys_unlink+0x1c6>
    end_op();
    800058a6:	fffff097          	auipc	ra,0xfffff
    800058aa:	ad0080e7          	jalr	-1328(ra) # 80004376 <end_op>
    return -1;
    800058ae:	557d                	li	a0,-1
    800058b0:	64ee                	ld	s1,216(sp)
    800058b2:	a055                	j	80005956 <sys_unlink+0x1c6>
    800058b4:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800058b6:	00003517          	auipc	a0,0x3
    800058ba:	e8250513          	add	a0,a0,-382 # 80008738 <states.0+0x230>
    800058be:	ffffb097          	auipc	ra,0xffffb
    800058c2:	ca2080e7          	jalr	-862(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058c6:	04c92703          	lw	a4,76(s2)
    800058ca:	02000793          	li	a5,32
    800058ce:	f6e7f5e3          	bgeu	a5,a4,80005838 <sys_unlink+0xa8>
    800058d2:	e5ce                	sd	s3,200(sp)
    800058d4:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058d8:	4741                	li	a4,16
    800058da:	86ce                	mv	a3,s3
    800058dc:	f1840613          	add	a2,s0,-232
    800058e0:	4581                	li	a1,0
    800058e2:	854a                	mv	a0,s2
    800058e4:	ffffe097          	auipc	ra,0xffffe
    800058e8:	302080e7          	jalr	770(ra) # 80003be6 <readi>
    800058ec:	47c1                	li	a5,16
    800058ee:	00f51c63          	bne	a0,a5,80005906 <sys_unlink+0x176>
    if(de.inum != 0)
    800058f2:	f1845783          	lhu	a5,-232(s0)
    800058f6:	e7b5                	bnez	a5,80005962 <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058f8:	29c1                	addw	s3,s3,16
    800058fa:	04c92783          	lw	a5,76(s2)
    800058fe:	fcf9ede3          	bltu	s3,a5,800058d8 <sys_unlink+0x148>
    80005902:	69ae                	ld	s3,200(sp)
    80005904:	bf15                	j	80005838 <sys_unlink+0xa8>
      panic("isdirempty: readi");
    80005906:	00003517          	auipc	a0,0x3
    8000590a:	e4a50513          	add	a0,a0,-438 # 80008750 <states.0+0x248>
    8000590e:	ffffb097          	auipc	ra,0xffffb
    80005912:	c52080e7          	jalr	-942(ra) # 80000560 <panic>
    80005916:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005918:	00003517          	auipc	a0,0x3
    8000591c:	e5050513          	add	a0,a0,-432 # 80008768 <states.0+0x260>
    80005920:	ffffb097          	auipc	ra,0xffffb
    80005924:	c40080e7          	jalr	-960(ra) # 80000560 <panic>
    dp->nlink--;
    80005928:	04a4d783          	lhu	a5,74(s1)
    8000592c:	37fd                	addw	a5,a5,-1
    8000592e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005932:	8526                	mv	a0,s1
    80005934:	ffffe097          	auipc	ra,0xffffe
    80005938:	f2e080e7          	jalr	-210(ra) # 80003862 <iupdate>
    8000593c:	bf0d                	j	8000586e <sys_unlink+0xde>
    8000593e:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005940:	8526                	mv	a0,s1
    80005942:	ffffe097          	auipc	ra,0xffffe
    80005946:	252080e7          	jalr	594(ra) # 80003b94 <iunlockput>
  end_op();
    8000594a:	fffff097          	auipc	ra,0xfffff
    8000594e:	a2c080e7          	jalr	-1492(ra) # 80004376 <end_op>
  return -1;
    80005952:	557d                	li	a0,-1
    80005954:	64ee                	ld	s1,216(sp)
}
    80005956:	70ae                	ld	ra,232(sp)
    80005958:	740e                	ld	s0,224(sp)
    8000595a:	616d                	add	sp,sp,240
    8000595c:	8082                	ret
    return -1;
    8000595e:	557d                	li	a0,-1
    80005960:	bfdd                	j	80005956 <sys_unlink+0x1c6>
    iunlockput(ip);
    80005962:	854a                	mv	a0,s2
    80005964:	ffffe097          	auipc	ra,0xffffe
    80005968:	230080e7          	jalr	560(ra) # 80003b94 <iunlockput>
    goto bad;
    8000596c:	694e                	ld	s2,208(sp)
    8000596e:	69ae                	ld	s3,200(sp)
    80005970:	bfc1                	j	80005940 <sys_unlink+0x1b0>

0000000080005972 <sys_open>:

uint64
sys_open(void)
{
    80005972:	7131                	add	sp,sp,-192
    80005974:	fd06                	sd	ra,184(sp)
    80005976:	f922                	sd	s0,176(sp)
    80005978:	0180                	add	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000597a:	f4c40593          	add	a1,s0,-180
    8000597e:	4505                	li	a0,1
    80005980:	ffffd097          	auipc	ra,0xffffd
    80005984:	210080e7          	jalr	528(ra) # 80002b90 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005988:	08000613          	li	a2,128
    8000598c:	f5040593          	add	a1,s0,-176
    80005990:	4501                	li	a0,0
    80005992:	ffffd097          	auipc	ra,0xffffd
    80005996:	23e080e7          	jalr	574(ra) # 80002bd0 <argstr>
    8000599a:	87aa                	mv	a5,a0
    return -1;
    8000599c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000599e:	0a07ce63          	bltz	a5,80005a5a <sys_open+0xe8>
    800059a2:	f526                	sd	s1,168(sp)

  begin_op();
    800059a4:	fffff097          	auipc	ra,0xfffff
    800059a8:	958080e7          	jalr	-1704(ra) # 800042fc <begin_op>

  if(omode & O_CREATE){
    800059ac:	f4c42783          	lw	a5,-180(s0)
    800059b0:	2007f793          	and	a5,a5,512
    800059b4:	cfd5                	beqz	a5,80005a70 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800059b6:	4681                	li	a3,0
    800059b8:	4601                	li	a2,0
    800059ba:	4589                	li	a1,2
    800059bc:	f5040513          	add	a0,s0,-176
    800059c0:	00000097          	auipc	ra,0x0
    800059c4:	95c080e7          	jalr	-1700(ra) # 8000531c <create>
    800059c8:	84aa                	mv	s1,a0
    if(ip == 0){
    800059ca:	cd41                	beqz	a0,80005a62 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800059cc:	04449703          	lh	a4,68(s1)
    800059d0:	478d                	li	a5,3
    800059d2:	00f71763          	bne	a4,a5,800059e0 <sys_open+0x6e>
    800059d6:	0464d703          	lhu	a4,70(s1)
    800059da:	47a5                	li	a5,9
    800059dc:	0ee7e163          	bltu	a5,a4,80005abe <sys_open+0x14c>
    800059e0:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800059e2:	fffff097          	auipc	ra,0xfffff
    800059e6:	d28080e7          	jalr	-728(ra) # 8000470a <filealloc>
    800059ea:	892a                	mv	s2,a0
    800059ec:	c97d                	beqz	a0,80005ae2 <sys_open+0x170>
    800059ee:	ed4e                	sd	s3,152(sp)
    800059f0:	00000097          	auipc	ra,0x0
    800059f4:	8ea080e7          	jalr	-1814(ra) # 800052da <fdalloc>
    800059f8:	89aa                	mv	s3,a0
    800059fa:	0c054e63          	bltz	a0,80005ad6 <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800059fe:	04449703          	lh	a4,68(s1)
    80005a02:	478d                	li	a5,3
    80005a04:	0ef70c63          	beq	a4,a5,80005afc <sys_open+0x18a>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005a08:	4789                	li	a5,2
    80005a0a:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005a0e:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005a12:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005a16:	f4c42783          	lw	a5,-180(s0)
    80005a1a:	0017c713          	xor	a4,a5,1
    80005a1e:	8b05                	and	a4,a4,1
    80005a20:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005a24:	0037f713          	and	a4,a5,3
    80005a28:	00e03733          	snez	a4,a4
    80005a2c:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005a30:	4007f793          	and	a5,a5,1024
    80005a34:	c791                	beqz	a5,80005a40 <sys_open+0xce>
    80005a36:	04449703          	lh	a4,68(s1)
    80005a3a:	4789                	li	a5,2
    80005a3c:	0cf70763          	beq	a4,a5,80005b0a <sys_open+0x198>
    itrunc(ip);
  }

  iunlock(ip);
    80005a40:	8526                	mv	a0,s1
    80005a42:	ffffe097          	auipc	ra,0xffffe
    80005a46:	fb2080e7          	jalr	-78(ra) # 800039f4 <iunlock>
  end_op();
    80005a4a:	fffff097          	auipc	ra,0xfffff
    80005a4e:	92c080e7          	jalr	-1748(ra) # 80004376 <end_op>

  return fd;
    80005a52:	854e                	mv	a0,s3
    80005a54:	74aa                	ld	s1,168(sp)
    80005a56:	790a                	ld	s2,160(sp)
    80005a58:	69ea                	ld	s3,152(sp)
}
    80005a5a:	70ea                	ld	ra,184(sp)
    80005a5c:	744a                	ld	s0,176(sp)
    80005a5e:	6129                	add	sp,sp,192
    80005a60:	8082                	ret
      end_op();
    80005a62:	fffff097          	auipc	ra,0xfffff
    80005a66:	914080e7          	jalr	-1772(ra) # 80004376 <end_op>
      return -1;
    80005a6a:	557d                	li	a0,-1
    80005a6c:	74aa                	ld	s1,168(sp)
    80005a6e:	b7f5                	j	80005a5a <sys_open+0xe8>
    if((ip = namei(path)) == 0){
    80005a70:	f5040513          	add	a0,s0,-176
    80005a74:	ffffe097          	auipc	ra,0xffffe
    80005a78:	688080e7          	jalr	1672(ra) # 800040fc <namei>
    80005a7c:	84aa                	mv	s1,a0
    80005a7e:	c90d                	beqz	a0,80005ab0 <sys_open+0x13e>
    ilock(ip);
    80005a80:	ffffe097          	auipc	ra,0xffffe
    80005a84:	eae080e7          	jalr	-338(ra) # 8000392e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a88:	04449703          	lh	a4,68(s1)
    80005a8c:	4785                	li	a5,1
    80005a8e:	f2f71fe3          	bne	a4,a5,800059cc <sys_open+0x5a>
    80005a92:	f4c42783          	lw	a5,-180(s0)
    80005a96:	d7a9                	beqz	a5,800059e0 <sys_open+0x6e>
      iunlockput(ip);
    80005a98:	8526                	mv	a0,s1
    80005a9a:	ffffe097          	auipc	ra,0xffffe
    80005a9e:	0fa080e7          	jalr	250(ra) # 80003b94 <iunlockput>
      end_op();
    80005aa2:	fffff097          	auipc	ra,0xfffff
    80005aa6:	8d4080e7          	jalr	-1836(ra) # 80004376 <end_op>
      return -1;
    80005aaa:	557d                	li	a0,-1
    80005aac:	74aa                	ld	s1,168(sp)
    80005aae:	b775                	j	80005a5a <sys_open+0xe8>
      end_op();
    80005ab0:	fffff097          	auipc	ra,0xfffff
    80005ab4:	8c6080e7          	jalr	-1850(ra) # 80004376 <end_op>
      return -1;
    80005ab8:	557d                	li	a0,-1
    80005aba:	74aa                	ld	s1,168(sp)
    80005abc:	bf79                	j	80005a5a <sys_open+0xe8>
    iunlockput(ip);
    80005abe:	8526                	mv	a0,s1
    80005ac0:	ffffe097          	auipc	ra,0xffffe
    80005ac4:	0d4080e7          	jalr	212(ra) # 80003b94 <iunlockput>
    end_op();
    80005ac8:	fffff097          	auipc	ra,0xfffff
    80005acc:	8ae080e7          	jalr	-1874(ra) # 80004376 <end_op>
    return -1;
    80005ad0:	557d                	li	a0,-1
    80005ad2:	74aa                	ld	s1,168(sp)
    80005ad4:	b759                	j	80005a5a <sys_open+0xe8>
      fileclose(f);
    80005ad6:	854a                	mv	a0,s2
    80005ad8:	fffff097          	auipc	ra,0xfffff
    80005adc:	cee080e7          	jalr	-786(ra) # 800047c6 <fileclose>
    80005ae0:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005ae2:	8526                	mv	a0,s1
    80005ae4:	ffffe097          	auipc	ra,0xffffe
    80005ae8:	0b0080e7          	jalr	176(ra) # 80003b94 <iunlockput>
    end_op();
    80005aec:	fffff097          	auipc	ra,0xfffff
    80005af0:	88a080e7          	jalr	-1910(ra) # 80004376 <end_op>
    return -1;
    80005af4:	557d                	li	a0,-1
    80005af6:	74aa                	ld	s1,168(sp)
    80005af8:	790a                	ld	s2,160(sp)
    80005afa:	b785                	j	80005a5a <sys_open+0xe8>
    f->type = FD_DEVICE;
    80005afc:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005b00:	04649783          	lh	a5,70(s1)
    80005b04:	02f91223          	sh	a5,36(s2)
    80005b08:	b729                	j	80005a12 <sys_open+0xa0>
    itrunc(ip);
    80005b0a:	8526                	mv	a0,s1
    80005b0c:	ffffe097          	auipc	ra,0xffffe
    80005b10:	f34080e7          	jalr	-204(ra) # 80003a40 <itrunc>
    80005b14:	b735                	j	80005a40 <sys_open+0xce>

0000000080005b16 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005b16:	7175                	add	sp,sp,-144
    80005b18:	e506                	sd	ra,136(sp)
    80005b1a:	e122                	sd	s0,128(sp)
    80005b1c:	0900                	add	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005b1e:	ffffe097          	auipc	ra,0xffffe
    80005b22:	7de080e7          	jalr	2014(ra) # 800042fc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005b26:	08000613          	li	a2,128
    80005b2a:	f7040593          	add	a1,s0,-144
    80005b2e:	4501                	li	a0,0
    80005b30:	ffffd097          	auipc	ra,0xffffd
    80005b34:	0a0080e7          	jalr	160(ra) # 80002bd0 <argstr>
    80005b38:	02054963          	bltz	a0,80005b6a <sys_mkdir+0x54>
    80005b3c:	4681                	li	a3,0
    80005b3e:	4601                	li	a2,0
    80005b40:	4585                	li	a1,1
    80005b42:	f7040513          	add	a0,s0,-144
    80005b46:	fffff097          	auipc	ra,0xfffff
    80005b4a:	7d6080e7          	jalr	2006(ra) # 8000531c <create>
    80005b4e:	cd11                	beqz	a0,80005b6a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b50:	ffffe097          	auipc	ra,0xffffe
    80005b54:	044080e7          	jalr	68(ra) # 80003b94 <iunlockput>
  end_op();
    80005b58:	fffff097          	auipc	ra,0xfffff
    80005b5c:	81e080e7          	jalr	-2018(ra) # 80004376 <end_op>
  return 0;
    80005b60:	4501                	li	a0,0
}
    80005b62:	60aa                	ld	ra,136(sp)
    80005b64:	640a                	ld	s0,128(sp)
    80005b66:	6149                	add	sp,sp,144
    80005b68:	8082                	ret
    end_op();
    80005b6a:	fffff097          	auipc	ra,0xfffff
    80005b6e:	80c080e7          	jalr	-2036(ra) # 80004376 <end_op>
    return -1;
    80005b72:	557d                	li	a0,-1
    80005b74:	b7fd                	j	80005b62 <sys_mkdir+0x4c>

0000000080005b76 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b76:	7135                	add	sp,sp,-160
    80005b78:	ed06                	sd	ra,152(sp)
    80005b7a:	e922                	sd	s0,144(sp)
    80005b7c:	1100                	add	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b7e:	ffffe097          	auipc	ra,0xffffe
    80005b82:	77e080e7          	jalr	1918(ra) # 800042fc <begin_op>
  argint(1, &major);
    80005b86:	f6c40593          	add	a1,s0,-148
    80005b8a:	4505                	li	a0,1
    80005b8c:	ffffd097          	auipc	ra,0xffffd
    80005b90:	004080e7          	jalr	4(ra) # 80002b90 <argint>
  argint(2, &minor);
    80005b94:	f6840593          	add	a1,s0,-152
    80005b98:	4509                	li	a0,2
    80005b9a:	ffffd097          	auipc	ra,0xffffd
    80005b9e:	ff6080e7          	jalr	-10(ra) # 80002b90 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ba2:	08000613          	li	a2,128
    80005ba6:	f7040593          	add	a1,s0,-144
    80005baa:	4501                	li	a0,0
    80005bac:	ffffd097          	auipc	ra,0xffffd
    80005bb0:	024080e7          	jalr	36(ra) # 80002bd0 <argstr>
    80005bb4:	02054b63          	bltz	a0,80005bea <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005bb8:	f6841683          	lh	a3,-152(s0)
    80005bbc:	f6c41603          	lh	a2,-148(s0)
    80005bc0:	458d                	li	a1,3
    80005bc2:	f7040513          	add	a0,s0,-144
    80005bc6:	fffff097          	auipc	ra,0xfffff
    80005bca:	756080e7          	jalr	1878(ra) # 8000531c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005bce:	cd11                	beqz	a0,80005bea <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005bd0:	ffffe097          	auipc	ra,0xffffe
    80005bd4:	fc4080e7          	jalr	-60(ra) # 80003b94 <iunlockput>
  end_op();
    80005bd8:	ffffe097          	auipc	ra,0xffffe
    80005bdc:	79e080e7          	jalr	1950(ra) # 80004376 <end_op>
  return 0;
    80005be0:	4501                	li	a0,0
}
    80005be2:	60ea                	ld	ra,152(sp)
    80005be4:	644a                	ld	s0,144(sp)
    80005be6:	610d                	add	sp,sp,160
    80005be8:	8082                	ret
    end_op();
    80005bea:	ffffe097          	auipc	ra,0xffffe
    80005bee:	78c080e7          	jalr	1932(ra) # 80004376 <end_op>
    return -1;
    80005bf2:	557d                	li	a0,-1
    80005bf4:	b7fd                	j	80005be2 <sys_mknod+0x6c>

0000000080005bf6 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005bf6:	7135                	add	sp,sp,-160
    80005bf8:	ed06                	sd	ra,152(sp)
    80005bfa:	e922                	sd	s0,144(sp)
    80005bfc:	e14a                	sd	s2,128(sp)
    80005bfe:	1100                	add	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005c00:	ffffc097          	auipc	ra,0xffffc
    80005c04:	e4a080e7          	jalr	-438(ra) # 80001a4a <myproc>
    80005c08:	892a                	mv	s2,a0
  
  begin_op();
    80005c0a:	ffffe097          	auipc	ra,0xffffe
    80005c0e:	6f2080e7          	jalr	1778(ra) # 800042fc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005c12:	08000613          	li	a2,128
    80005c16:	f6040593          	add	a1,s0,-160
    80005c1a:	4501                	li	a0,0
    80005c1c:	ffffd097          	auipc	ra,0xffffd
    80005c20:	fb4080e7          	jalr	-76(ra) # 80002bd0 <argstr>
    80005c24:	04054d63          	bltz	a0,80005c7e <sys_chdir+0x88>
    80005c28:	e526                	sd	s1,136(sp)
    80005c2a:	f6040513          	add	a0,s0,-160
    80005c2e:	ffffe097          	auipc	ra,0xffffe
    80005c32:	4ce080e7          	jalr	1230(ra) # 800040fc <namei>
    80005c36:	84aa                	mv	s1,a0
    80005c38:	c131                	beqz	a0,80005c7c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005c3a:	ffffe097          	auipc	ra,0xffffe
    80005c3e:	cf4080e7          	jalr	-780(ra) # 8000392e <ilock>
  if(ip->type != T_DIR){
    80005c42:	04449703          	lh	a4,68(s1)
    80005c46:	4785                	li	a5,1
    80005c48:	04f71163          	bne	a4,a5,80005c8a <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005c4c:	8526                	mv	a0,s1
    80005c4e:	ffffe097          	auipc	ra,0xffffe
    80005c52:	da6080e7          	jalr	-602(ra) # 800039f4 <iunlock>
  iput(p->cwd);
    80005c56:	16893503          	ld	a0,360(s2)
    80005c5a:	ffffe097          	auipc	ra,0xffffe
    80005c5e:	e92080e7          	jalr	-366(ra) # 80003aec <iput>
  end_op();
    80005c62:	ffffe097          	auipc	ra,0xffffe
    80005c66:	714080e7          	jalr	1812(ra) # 80004376 <end_op>
  p->cwd = ip;
    80005c6a:	16993423          	sd	s1,360(s2)
  return 0;
    80005c6e:	4501                	li	a0,0
    80005c70:	64aa                	ld	s1,136(sp)
}
    80005c72:	60ea                	ld	ra,152(sp)
    80005c74:	644a                	ld	s0,144(sp)
    80005c76:	690a                	ld	s2,128(sp)
    80005c78:	610d                	add	sp,sp,160
    80005c7a:	8082                	ret
    80005c7c:	64aa                	ld	s1,136(sp)
    end_op();
    80005c7e:	ffffe097          	auipc	ra,0xffffe
    80005c82:	6f8080e7          	jalr	1784(ra) # 80004376 <end_op>
    return -1;
    80005c86:	557d                	li	a0,-1
    80005c88:	b7ed                	j	80005c72 <sys_chdir+0x7c>
    iunlockput(ip);
    80005c8a:	8526                	mv	a0,s1
    80005c8c:	ffffe097          	auipc	ra,0xffffe
    80005c90:	f08080e7          	jalr	-248(ra) # 80003b94 <iunlockput>
    end_op();
    80005c94:	ffffe097          	auipc	ra,0xffffe
    80005c98:	6e2080e7          	jalr	1762(ra) # 80004376 <end_op>
    return -1;
    80005c9c:	557d                	li	a0,-1
    80005c9e:	64aa                	ld	s1,136(sp)
    80005ca0:	bfc9                	j	80005c72 <sys_chdir+0x7c>

0000000080005ca2 <sys_exec>:

uint64
sys_exec(void)
{
    80005ca2:	7121                	add	sp,sp,-448
    80005ca4:	ff06                	sd	ra,440(sp)
    80005ca6:	fb22                	sd	s0,432(sp)
    80005ca8:	0380                	add	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005caa:	e4840593          	add	a1,s0,-440
    80005cae:	4505                	li	a0,1
    80005cb0:	ffffd097          	auipc	ra,0xffffd
    80005cb4:	f00080e7          	jalr	-256(ra) # 80002bb0 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005cb8:	08000613          	li	a2,128
    80005cbc:	f5040593          	add	a1,s0,-176
    80005cc0:	4501                	li	a0,0
    80005cc2:	ffffd097          	auipc	ra,0xffffd
    80005cc6:	f0e080e7          	jalr	-242(ra) # 80002bd0 <argstr>
    80005cca:	87aa                	mv	a5,a0
    return -1;
    80005ccc:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005cce:	0e07c263          	bltz	a5,80005db2 <sys_exec+0x110>
    80005cd2:	f726                	sd	s1,424(sp)
    80005cd4:	f34a                	sd	s2,416(sp)
    80005cd6:	ef4e                	sd	s3,408(sp)
    80005cd8:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005cda:	10000613          	li	a2,256
    80005cde:	4581                	li	a1,0
    80005ce0:	e5040513          	add	a0,s0,-432
    80005ce4:	ffffb097          	auipc	ra,0xffffb
    80005ce8:	050080e7          	jalr	80(ra) # 80000d34 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005cec:	e5040493          	add	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005cf0:	89a6                	mv	s3,s1
    80005cf2:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005cf4:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005cf8:	00391513          	sll	a0,s2,0x3
    80005cfc:	e4040593          	add	a1,s0,-448
    80005d00:	e4843783          	ld	a5,-440(s0)
    80005d04:	953e                	add	a0,a0,a5
    80005d06:	ffffd097          	auipc	ra,0xffffd
    80005d0a:	dec080e7          	jalr	-532(ra) # 80002af2 <fetchaddr>
    80005d0e:	02054a63          	bltz	a0,80005d42 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005d12:	e4043783          	ld	a5,-448(s0)
    80005d16:	c7b9                	beqz	a5,80005d64 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005d18:	ffffb097          	auipc	ra,0xffffb
    80005d1c:	e30080e7          	jalr	-464(ra) # 80000b48 <kalloc>
    80005d20:	85aa                	mv	a1,a0
    80005d22:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005d26:	cd11                	beqz	a0,80005d42 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d28:	6605                	lui	a2,0x1
    80005d2a:	e4043503          	ld	a0,-448(s0)
    80005d2e:	ffffd097          	auipc	ra,0xffffd
    80005d32:	e16080e7          	jalr	-490(ra) # 80002b44 <fetchstr>
    80005d36:	00054663          	bltz	a0,80005d42 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005d3a:	0905                	add	s2,s2,1
    80005d3c:	09a1                	add	s3,s3,8
    80005d3e:	fb491de3          	bne	s2,s4,80005cf8 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d42:	f5040913          	add	s2,s0,-176
    80005d46:	6088                	ld	a0,0(s1)
    80005d48:	c125                	beqz	a0,80005da8 <sys_exec+0x106>
    kfree(argv[i]);
    80005d4a:	ffffb097          	auipc	ra,0xffffb
    80005d4e:	d00080e7          	jalr	-768(ra) # 80000a4a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d52:	04a1                	add	s1,s1,8
    80005d54:	ff2499e3          	bne	s1,s2,80005d46 <sys_exec+0xa4>
  return -1;
    80005d58:	557d                	li	a0,-1
    80005d5a:	74ba                	ld	s1,424(sp)
    80005d5c:	791a                	ld	s2,416(sp)
    80005d5e:	69fa                	ld	s3,408(sp)
    80005d60:	6a5a                	ld	s4,400(sp)
    80005d62:	a881                	j	80005db2 <sys_exec+0x110>
      argv[i] = 0;
    80005d64:	0009079b          	sext.w	a5,s2
    80005d68:	078e                	sll	a5,a5,0x3
    80005d6a:	fd078793          	add	a5,a5,-48
    80005d6e:	97a2                	add	a5,a5,s0
    80005d70:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005d74:	e5040593          	add	a1,s0,-432
    80005d78:	f5040513          	add	a0,s0,-176
    80005d7c:	fffff097          	auipc	ra,0xfffff
    80005d80:	120080e7          	jalr	288(ra) # 80004e9c <exec>
    80005d84:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d86:	f5040993          	add	s3,s0,-176
    80005d8a:	6088                	ld	a0,0(s1)
    80005d8c:	c901                	beqz	a0,80005d9c <sys_exec+0xfa>
    kfree(argv[i]);
    80005d8e:	ffffb097          	auipc	ra,0xffffb
    80005d92:	cbc080e7          	jalr	-836(ra) # 80000a4a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d96:	04a1                	add	s1,s1,8
    80005d98:	ff3499e3          	bne	s1,s3,80005d8a <sys_exec+0xe8>
  return ret;
    80005d9c:	854a                	mv	a0,s2
    80005d9e:	74ba                	ld	s1,424(sp)
    80005da0:	791a                	ld	s2,416(sp)
    80005da2:	69fa                	ld	s3,408(sp)
    80005da4:	6a5a                	ld	s4,400(sp)
    80005da6:	a031                	j	80005db2 <sys_exec+0x110>
  return -1;
    80005da8:	557d                	li	a0,-1
    80005daa:	74ba                	ld	s1,424(sp)
    80005dac:	791a                	ld	s2,416(sp)
    80005dae:	69fa                	ld	s3,408(sp)
    80005db0:	6a5a                	ld	s4,400(sp)
}
    80005db2:	70fa                	ld	ra,440(sp)
    80005db4:	745a                	ld	s0,432(sp)
    80005db6:	6139                	add	sp,sp,448
    80005db8:	8082                	ret

0000000080005dba <sys_pipe>:

uint64
sys_pipe(void)
{
    80005dba:	7139                	add	sp,sp,-64
    80005dbc:	fc06                	sd	ra,56(sp)
    80005dbe:	f822                	sd	s0,48(sp)
    80005dc0:	f426                	sd	s1,40(sp)
    80005dc2:	0080                	add	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005dc4:	ffffc097          	auipc	ra,0xffffc
    80005dc8:	c86080e7          	jalr	-890(ra) # 80001a4a <myproc>
    80005dcc:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005dce:	fd840593          	add	a1,s0,-40
    80005dd2:	4501                	li	a0,0
    80005dd4:	ffffd097          	auipc	ra,0xffffd
    80005dd8:	ddc080e7          	jalr	-548(ra) # 80002bb0 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005ddc:	fc840593          	add	a1,s0,-56
    80005de0:	fd040513          	add	a0,s0,-48
    80005de4:	fffff097          	auipc	ra,0xfffff
    80005de8:	d50080e7          	jalr	-688(ra) # 80004b34 <pipealloc>
    return -1;
    80005dec:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005dee:	0c054463          	bltz	a0,80005eb6 <sys_pipe+0xfc>
  fd0 = -1;
    80005df2:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005df6:	fd043503          	ld	a0,-48(s0)
    80005dfa:	fffff097          	auipc	ra,0xfffff
    80005dfe:	4e0080e7          	jalr	1248(ra) # 800052da <fdalloc>
    80005e02:	fca42223          	sw	a0,-60(s0)
    80005e06:	08054b63          	bltz	a0,80005e9c <sys_pipe+0xe2>
    80005e0a:	fc843503          	ld	a0,-56(s0)
    80005e0e:	fffff097          	auipc	ra,0xfffff
    80005e12:	4cc080e7          	jalr	1228(ra) # 800052da <fdalloc>
    80005e16:	fca42023          	sw	a0,-64(s0)
    80005e1a:	06054863          	bltz	a0,80005e8a <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e1e:	4691                	li	a3,4
    80005e20:	fc440613          	add	a2,s0,-60
    80005e24:	fd843583          	ld	a1,-40(s0)
    80005e28:	74a8                	ld	a0,104(s1)
    80005e2a:	ffffc097          	auipc	ra,0xffffc
    80005e2e:	8b8080e7          	jalr	-1864(ra) # 800016e2 <copyout>
    80005e32:	02054063          	bltz	a0,80005e52 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005e36:	4691                	li	a3,4
    80005e38:	fc040613          	add	a2,s0,-64
    80005e3c:	fd843583          	ld	a1,-40(s0)
    80005e40:	0591                	add	a1,a1,4
    80005e42:	74a8                	ld	a0,104(s1)
    80005e44:	ffffc097          	auipc	ra,0xffffc
    80005e48:	89e080e7          	jalr	-1890(ra) # 800016e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e4c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e4e:	06055463          	bgez	a0,80005eb6 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005e52:	fc442783          	lw	a5,-60(s0)
    80005e56:	07f1                	add	a5,a5,28
    80005e58:	078e                	sll	a5,a5,0x3
    80005e5a:	97a6                	add	a5,a5,s1
    80005e5c:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005e60:	fc042783          	lw	a5,-64(s0)
    80005e64:	07f1                	add	a5,a5,28
    80005e66:	078e                	sll	a5,a5,0x3
    80005e68:	94be                	add	s1,s1,a5
    80005e6a:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005e6e:	fd043503          	ld	a0,-48(s0)
    80005e72:	fffff097          	auipc	ra,0xfffff
    80005e76:	954080e7          	jalr	-1708(ra) # 800047c6 <fileclose>
    fileclose(wf);
    80005e7a:	fc843503          	ld	a0,-56(s0)
    80005e7e:	fffff097          	auipc	ra,0xfffff
    80005e82:	948080e7          	jalr	-1720(ra) # 800047c6 <fileclose>
    return -1;
    80005e86:	57fd                	li	a5,-1
    80005e88:	a03d                	j	80005eb6 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005e8a:	fc442783          	lw	a5,-60(s0)
    80005e8e:	0007c763          	bltz	a5,80005e9c <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005e92:	07f1                	add	a5,a5,28
    80005e94:	078e                	sll	a5,a5,0x3
    80005e96:	97a6                	add	a5,a5,s1
    80005e98:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80005e9c:	fd043503          	ld	a0,-48(s0)
    80005ea0:	fffff097          	auipc	ra,0xfffff
    80005ea4:	926080e7          	jalr	-1754(ra) # 800047c6 <fileclose>
    fileclose(wf);
    80005ea8:	fc843503          	ld	a0,-56(s0)
    80005eac:	fffff097          	auipc	ra,0xfffff
    80005eb0:	91a080e7          	jalr	-1766(ra) # 800047c6 <fileclose>
    return -1;
    80005eb4:	57fd                	li	a5,-1
}
    80005eb6:	853e                	mv	a0,a5
    80005eb8:	70e2                	ld	ra,56(sp)
    80005eba:	7442                	ld	s0,48(sp)
    80005ebc:	74a2                	ld	s1,40(sp)
    80005ebe:	6121                	add	sp,sp,64
    80005ec0:	8082                	ret
	...

0000000080005ed0 <kernelvec>:
    80005ed0:	7111                	add	sp,sp,-256
    80005ed2:	e006                	sd	ra,0(sp)
    80005ed4:	e40a                	sd	sp,8(sp)
    80005ed6:	e80e                	sd	gp,16(sp)
    80005ed8:	ec12                	sd	tp,24(sp)
    80005eda:	f016                	sd	t0,32(sp)
    80005edc:	f41a                	sd	t1,40(sp)
    80005ede:	f81e                	sd	t2,48(sp)
    80005ee0:	fc22                	sd	s0,56(sp)
    80005ee2:	e0a6                	sd	s1,64(sp)
    80005ee4:	e4aa                	sd	a0,72(sp)
    80005ee6:	e8ae                	sd	a1,80(sp)
    80005ee8:	ecb2                	sd	a2,88(sp)
    80005eea:	f0b6                	sd	a3,96(sp)
    80005eec:	f4ba                	sd	a4,104(sp)
    80005eee:	f8be                	sd	a5,112(sp)
    80005ef0:	fcc2                	sd	a6,120(sp)
    80005ef2:	e146                	sd	a7,128(sp)
    80005ef4:	e54a                	sd	s2,136(sp)
    80005ef6:	e94e                	sd	s3,144(sp)
    80005ef8:	ed52                	sd	s4,152(sp)
    80005efa:	f156                	sd	s5,160(sp)
    80005efc:	f55a                	sd	s6,168(sp)
    80005efe:	f95e                	sd	s7,176(sp)
    80005f00:	fd62                	sd	s8,184(sp)
    80005f02:	e1e6                	sd	s9,192(sp)
    80005f04:	e5ea                	sd	s10,200(sp)
    80005f06:	e9ee                	sd	s11,208(sp)
    80005f08:	edf2                	sd	t3,216(sp)
    80005f0a:	f1f6                	sd	t4,224(sp)
    80005f0c:	f5fa                	sd	t5,232(sp)
    80005f0e:	f9fe                	sd	t6,240(sp)
    80005f10:	aaffc0ef          	jal	800029be <kerneltrap>
    80005f14:	6082                	ld	ra,0(sp)
    80005f16:	6122                	ld	sp,8(sp)
    80005f18:	61c2                	ld	gp,16(sp)
    80005f1a:	7282                	ld	t0,32(sp)
    80005f1c:	7322                	ld	t1,40(sp)
    80005f1e:	73c2                	ld	t2,48(sp)
    80005f20:	7462                	ld	s0,56(sp)
    80005f22:	6486                	ld	s1,64(sp)
    80005f24:	6526                	ld	a0,72(sp)
    80005f26:	65c6                	ld	a1,80(sp)
    80005f28:	6666                	ld	a2,88(sp)
    80005f2a:	7686                	ld	a3,96(sp)
    80005f2c:	7726                	ld	a4,104(sp)
    80005f2e:	77c6                	ld	a5,112(sp)
    80005f30:	7866                	ld	a6,120(sp)
    80005f32:	688a                	ld	a7,128(sp)
    80005f34:	692a                	ld	s2,136(sp)
    80005f36:	69ca                	ld	s3,144(sp)
    80005f38:	6a6a                	ld	s4,152(sp)
    80005f3a:	7a8a                	ld	s5,160(sp)
    80005f3c:	7b2a                	ld	s6,168(sp)
    80005f3e:	7bca                	ld	s7,176(sp)
    80005f40:	7c6a                	ld	s8,184(sp)
    80005f42:	6c8e                	ld	s9,192(sp)
    80005f44:	6d2e                	ld	s10,200(sp)
    80005f46:	6dce                	ld	s11,208(sp)
    80005f48:	6e6e                	ld	t3,216(sp)
    80005f4a:	7e8e                	ld	t4,224(sp)
    80005f4c:	7f2e                	ld	t5,232(sp)
    80005f4e:	7fce                	ld	t6,240(sp)
    80005f50:	6111                	add	sp,sp,256
    80005f52:	10200073          	sret
    80005f56:	00000013          	nop
    80005f5a:	00000013          	nop
    80005f5e:	0001                	nop

0000000080005f60 <timervec>:
    80005f60:	34051573          	csrrw	a0,mscratch,a0
    80005f64:	e10c                	sd	a1,0(a0)
    80005f66:	e510                	sd	a2,8(a0)
    80005f68:	e914                	sd	a3,16(a0)
    80005f6a:	6d0c                	ld	a1,24(a0)
    80005f6c:	7110                	ld	a2,32(a0)
    80005f6e:	6194                	ld	a3,0(a1)
    80005f70:	96b2                	add	a3,a3,a2
    80005f72:	e194                	sd	a3,0(a1)
    80005f74:	4589                	li	a1,2
    80005f76:	14459073          	csrw	sip,a1
    80005f7a:	6914                	ld	a3,16(a0)
    80005f7c:	6510                	ld	a2,8(a0)
    80005f7e:	610c                	ld	a1,0(a0)
    80005f80:	34051573          	csrrw	a0,mscratch,a0
    80005f84:	30200073          	mret
	...

0000000080005f8a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f8a:	1141                	add	sp,sp,-16
    80005f8c:	e422                	sd	s0,8(sp)
    80005f8e:	0800                	add	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f90:	0c0007b7          	lui	a5,0xc000
    80005f94:	4705                	li	a4,1
    80005f96:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f98:	0c0007b7          	lui	a5,0xc000
    80005f9c:	c3d8                	sw	a4,4(a5)
}
    80005f9e:	6422                	ld	s0,8(sp)
    80005fa0:	0141                	add	sp,sp,16
    80005fa2:	8082                	ret

0000000080005fa4 <plicinithart>:

void
plicinithart(void)
{
    80005fa4:	1141                	add	sp,sp,-16
    80005fa6:	e406                	sd	ra,8(sp)
    80005fa8:	e022                	sd	s0,0(sp)
    80005faa:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005fac:	ffffc097          	auipc	ra,0xffffc
    80005fb0:	a72080e7          	jalr	-1422(ra) # 80001a1e <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005fb4:	0085171b          	sllw	a4,a0,0x8
    80005fb8:	0c0027b7          	lui	a5,0xc002
    80005fbc:	97ba                	add	a5,a5,a4
    80005fbe:	40200713          	li	a4,1026
    80005fc2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005fc6:	00d5151b          	sllw	a0,a0,0xd
    80005fca:	0c2017b7          	lui	a5,0xc201
    80005fce:	97aa                	add	a5,a5,a0
    80005fd0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005fd4:	60a2                	ld	ra,8(sp)
    80005fd6:	6402                	ld	s0,0(sp)
    80005fd8:	0141                	add	sp,sp,16
    80005fda:	8082                	ret

0000000080005fdc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005fdc:	1141                	add	sp,sp,-16
    80005fde:	e406                	sd	ra,8(sp)
    80005fe0:	e022                	sd	s0,0(sp)
    80005fe2:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005fe4:	ffffc097          	auipc	ra,0xffffc
    80005fe8:	a3a080e7          	jalr	-1478(ra) # 80001a1e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005fec:	00d5151b          	sllw	a0,a0,0xd
    80005ff0:	0c2017b7          	lui	a5,0xc201
    80005ff4:	97aa                	add	a5,a5,a0
  return irq;
}
    80005ff6:	43c8                	lw	a0,4(a5)
    80005ff8:	60a2                	ld	ra,8(sp)
    80005ffa:	6402                	ld	s0,0(sp)
    80005ffc:	0141                	add	sp,sp,16
    80005ffe:	8082                	ret

0000000080006000 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006000:	1101                	add	sp,sp,-32
    80006002:	ec06                	sd	ra,24(sp)
    80006004:	e822                	sd	s0,16(sp)
    80006006:	e426                	sd	s1,8(sp)
    80006008:	1000                	add	s0,sp,32
    8000600a:	84aa                	mv	s1,a0
  int hart = cpuid();
    8000600c:	ffffc097          	auipc	ra,0xffffc
    80006010:	a12080e7          	jalr	-1518(ra) # 80001a1e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006014:	00d5151b          	sllw	a0,a0,0xd
    80006018:	0c2017b7          	lui	a5,0xc201
    8000601c:	97aa                	add	a5,a5,a0
    8000601e:	c3c4                	sw	s1,4(a5)
}
    80006020:	60e2                	ld	ra,24(sp)
    80006022:	6442                	ld	s0,16(sp)
    80006024:	64a2                	ld	s1,8(sp)
    80006026:	6105                	add	sp,sp,32
    80006028:	8082                	ret

000000008000602a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000602a:	1141                	add	sp,sp,-16
    8000602c:	e406                	sd	ra,8(sp)
    8000602e:	e022                	sd	s0,0(sp)
    80006030:	0800                	add	s0,sp,16
  if(i >= NUM)
    80006032:	479d                	li	a5,7
    80006034:	04a7cc63          	blt	a5,a0,8000608c <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006038:	0001f797          	auipc	a5,0x1f
    8000603c:	b7878793          	add	a5,a5,-1160 # 80024bb0 <disk>
    80006040:	97aa                	add	a5,a5,a0
    80006042:	0187c783          	lbu	a5,24(a5)
    80006046:	ebb9                	bnez	a5,8000609c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006048:	00451693          	sll	a3,a0,0x4
    8000604c:	0001f797          	auipc	a5,0x1f
    80006050:	b6478793          	add	a5,a5,-1180 # 80024bb0 <disk>
    80006054:	6398                	ld	a4,0(a5)
    80006056:	9736                	add	a4,a4,a3
    80006058:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    8000605c:	6398                	ld	a4,0(a5)
    8000605e:	9736                	add	a4,a4,a3
    80006060:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006064:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006068:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    8000606c:	97aa                	add	a5,a5,a0
    8000606e:	4705                	li	a4,1
    80006070:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80006074:	0001f517          	auipc	a0,0x1f
    80006078:	b5450513          	add	a0,a0,-1196 # 80024bc8 <disk+0x18>
    8000607c:	ffffc097          	auipc	ra,0xffffc
    80006080:	0ee080e7          	jalr	238(ra) # 8000216a <wakeup>
}
    80006084:	60a2                	ld	ra,8(sp)
    80006086:	6402                	ld	s0,0(sp)
    80006088:	0141                	add	sp,sp,16
    8000608a:	8082                	ret
    panic("free_desc 1");
    8000608c:	00002517          	auipc	a0,0x2
    80006090:	6ec50513          	add	a0,a0,1772 # 80008778 <states.0+0x270>
    80006094:	ffffa097          	auipc	ra,0xffffa
    80006098:	4cc080e7          	jalr	1228(ra) # 80000560 <panic>
    panic("free_desc 2");
    8000609c:	00002517          	auipc	a0,0x2
    800060a0:	6ec50513          	add	a0,a0,1772 # 80008788 <states.0+0x280>
    800060a4:	ffffa097          	auipc	ra,0xffffa
    800060a8:	4bc080e7          	jalr	1212(ra) # 80000560 <panic>

00000000800060ac <virtio_disk_init>:
{
    800060ac:	1101                	add	sp,sp,-32
    800060ae:	ec06                	sd	ra,24(sp)
    800060b0:	e822                	sd	s0,16(sp)
    800060b2:	e426                	sd	s1,8(sp)
    800060b4:	e04a                	sd	s2,0(sp)
    800060b6:	1000                	add	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800060b8:	00002597          	auipc	a1,0x2
    800060bc:	6e058593          	add	a1,a1,1760 # 80008798 <states.0+0x290>
    800060c0:	0001f517          	auipc	a0,0x1f
    800060c4:	c1850513          	add	a0,a0,-1000 # 80024cd8 <disk+0x128>
    800060c8:	ffffb097          	auipc	ra,0xffffb
    800060cc:	ae0080e7          	jalr	-1312(ra) # 80000ba8 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060d0:	100017b7          	lui	a5,0x10001
    800060d4:	4398                	lw	a4,0(a5)
    800060d6:	2701                	sext.w	a4,a4
    800060d8:	747277b7          	lui	a5,0x74727
    800060dc:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800060e0:	18f71c63          	bne	a4,a5,80006278 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060e4:	100017b7          	lui	a5,0x10001
    800060e8:	0791                	add	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800060ea:	439c                	lw	a5,0(a5)
    800060ec:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800060ee:	4709                	li	a4,2
    800060f0:	18e79463          	bne	a5,a4,80006278 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800060f4:	100017b7          	lui	a5,0x10001
    800060f8:	07a1                	add	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800060fa:	439c                	lw	a5,0(a5)
    800060fc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800060fe:	16e79d63          	bne	a5,a4,80006278 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006102:	100017b7          	lui	a5,0x10001
    80006106:	47d8                	lw	a4,12(a5)
    80006108:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000610a:	554d47b7          	lui	a5,0x554d4
    8000610e:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006112:	16f71363          	bne	a4,a5,80006278 <virtio_disk_init+0x1cc>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006116:	100017b7          	lui	a5,0x10001
    8000611a:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000611e:	4705                	li	a4,1
    80006120:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006122:	470d                	li	a4,3
    80006124:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006126:	10001737          	lui	a4,0x10001
    8000612a:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000612c:	c7ffe737          	lui	a4,0xc7ffe
    80006130:	75f70713          	add	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd9a6f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006134:	8ef9                	and	a3,a3,a4
    80006136:	10001737          	lui	a4,0x10001
    8000613a:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000613c:	472d                	li	a4,11
    8000613e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006140:	07078793          	add	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80006144:	439c                	lw	a5,0(a5)
    80006146:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000614a:	8ba1                	and	a5,a5,8
    8000614c:	12078e63          	beqz	a5,80006288 <virtio_disk_init+0x1dc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006150:	100017b7          	lui	a5,0x10001
    80006154:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006158:	100017b7          	lui	a5,0x10001
    8000615c:	04478793          	add	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80006160:	439c                	lw	a5,0(a5)
    80006162:	2781                	sext.w	a5,a5
    80006164:	12079a63          	bnez	a5,80006298 <virtio_disk_init+0x1ec>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006168:	100017b7          	lui	a5,0x10001
    8000616c:	03478793          	add	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80006170:	439c                	lw	a5,0(a5)
    80006172:	2781                	sext.w	a5,a5
  if(max == 0)
    80006174:	12078a63          	beqz	a5,800062a8 <virtio_disk_init+0x1fc>
  if(max < NUM)
    80006178:	471d                	li	a4,7
    8000617a:	12f77f63          	bgeu	a4,a5,800062b8 <virtio_disk_init+0x20c>
  disk.desc = kalloc();
    8000617e:	ffffb097          	auipc	ra,0xffffb
    80006182:	9ca080e7          	jalr	-1590(ra) # 80000b48 <kalloc>
    80006186:	0001f497          	auipc	s1,0x1f
    8000618a:	a2a48493          	add	s1,s1,-1494 # 80024bb0 <disk>
    8000618e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006190:	ffffb097          	auipc	ra,0xffffb
    80006194:	9b8080e7          	jalr	-1608(ra) # 80000b48 <kalloc>
    80006198:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000619a:	ffffb097          	auipc	ra,0xffffb
    8000619e:	9ae080e7          	jalr	-1618(ra) # 80000b48 <kalloc>
    800061a2:	87aa                	mv	a5,a0
    800061a4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800061a6:	6088                	ld	a0,0(s1)
    800061a8:	12050063          	beqz	a0,800062c8 <virtio_disk_init+0x21c>
    800061ac:	0001f717          	auipc	a4,0x1f
    800061b0:	a0c73703          	ld	a4,-1524(a4) # 80024bb8 <disk+0x8>
    800061b4:	10070a63          	beqz	a4,800062c8 <virtio_disk_init+0x21c>
    800061b8:	10078863          	beqz	a5,800062c8 <virtio_disk_init+0x21c>
  memset(disk.desc, 0, PGSIZE);
    800061bc:	6605                	lui	a2,0x1
    800061be:	4581                	li	a1,0
    800061c0:	ffffb097          	auipc	ra,0xffffb
    800061c4:	b74080e7          	jalr	-1164(ra) # 80000d34 <memset>
  memset(disk.avail, 0, PGSIZE);
    800061c8:	0001f497          	auipc	s1,0x1f
    800061cc:	9e848493          	add	s1,s1,-1560 # 80024bb0 <disk>
    800061d0:	6605                	lui	a2,0x1
    800061d2:	4581                	li	a1,0
    800061d4:	6488                	ld	a0,8(s1)
    800061d6:	ffffb097          	auipc	ra,0xffffb
    800061da:	b5e080e7          	jalr	-1186(ra) # 80000d34 <memset>
  memset(disk.used, 0, PGSIZE);
    800061de:	6605                	lui	a2,0x1
    800061e0:	4581                	li	a1,0
    800061e2:	6888                	ld	a0,16(s1)
    800061e4:	ffffb097          	auipc	ra,0xffffb
    800061e8:	b50080e7          	jalr	-1200(ra) # 80000d34 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800061ec:	100017b7          	lui	a5,0x10001
    800061f0:	4721                	li	a4,8
    800061f2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800061f4:	4098                	lw	a4,0(s1)
    800061f6:	100017b7          	lui	a5,0x10001
    800061fa:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800061fe:	40d8                	lw	a4,4(s1)
    80006200:	100017b7          	lui	a5,0x10001
    80006204:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80006208:	649c                	ld	a5,8(s1)
    8000620a:	0007869b          	sext.w	a3,a5
    8000620e:	10001737          	lui	a4,0x10001
    80006212:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006216:	9781                	sra	a5,a5,0x20
    80006218:	10001737          	lui	a4,0x10001
    8000621c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006220:	689c                	ld	a5,16(s1)
    80006222:	0007869b          	sext.w	a3,a5
    80006226:	10001737          	lui	a4,0x10001
    8000622a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000622e:	9781                	sra	a5,a5,0x20
    80006230:	10001737          	lui	a4,0x10001
    80006234:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006238:	10001737          	lui	a4,0x10001
    8000623c:	4785                	li	a5,1
    8000623e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006240:	00f48c23          	sb	a5,24(s1)
    80006244:	00f48ca3          	sb	a5,25(s1)
    80006248:	00f48d23          	sb	a5,26(s1)
    8000624c:	00f48da3          	sb	a5,27(s1)
    80006250:	00f48e23          	sb	a5,28(s1)
    80006254:	00f48ea3          	sb	a5,29(s1)
    80006258:	00f48f23          	sb	a5,30(s1)
    8000625c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006260:	00496913          	or	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006264:	100017b7          	lui	a5,0x10001
    80006268:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000626c:	60e2                	ld	ra,24(sp)
    8000626e:	6442                	ld	s0,16(sp)
    80006270:	64a2                	ld	s1,8(sp)
    80006272:	6902                	ld	s2,0(sp)
    80006274:	6105                	add	sp,sp,32
    80006276:	8082                	ret
    panic("could not find virtio disk");
    80006278:	00002517          	auipc	a0,0x2
    8000627c:	53050513          	add	a0,a0,1328 # 800087a8 <states.0+0x2a0>
    80006280:	ffffa097          	auipc	ra,0xffffa
    80006284:	2e0080e7          	jalr	736(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006288:	00002517          	auipc	a0,0x2
    8000628c:	54050513          	add	a0,a0,1344 # 800087c8 <states.0+0x2c0>
    80006290:	ffffa097          	auipc	ra,0xffffa
    80006294:	2d0080e7          	jalr	720(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    80006298:	00002517          	auipc	a0,0x2
    8000629c:	55050513          	add	a0,a0,1360 # 800087e8 <states.0+0x2e0>
    800062a0:	ffffa097          	auipc	ra,0xffffa
    800062a4:	2c0080e7          	jalr	704(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    800062a8:	00002517          	auipc	a0,0x2
    800062ac:	56050513          	add	a0,a0,1376 # 80008808 <states.0+0x300>
    800062b0:	ffffa097          	auipc	ra,0xffffa
    800062b4:	2b0080e7          	jalr	688(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    800062b8:	00002517          	auipc	a0,0x2
    800062bc:	57050513          	add	a0,a0,1392 # 80008828 <states.0+0x320>
    800062c0:	ffffa097          	auipc	ra,0xffffa
    800062c4:	2a0080e7          	jalr	672(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    800062c8:	00002517          	auipc	a0,0x2
    800062cc:	58050513          	add	a0,a0,1408 # 80008848 <states.0+0x340>
    800062d0:	ffffa097          	auipc	ra,0xffffa
    800062d4:	290080e7          	jalr	656(ra) # 80000560 <panic>

00000000800062d8 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800062d8:	7159                	add	sp,sp,-112
    800062da:	f486                	sd	ra,104(sp)
    800062dc:	f0a2                	sd	s0,96(sp)
    800062de:	eca6                	sd	s1,88(sp)
    800062e0:	e8ca                	sd	s2,80(sp)
    800062e2:	e4ce                	sd	s3,72(sp)
    800062e4:	e0d2                	sd	s4,64(sp)
    800062e6:	fc56                	sd	s5,56(sp)
    800062e8:	f85a                	sd	s6,48(sp)
    800062ea:	f45e                	sd	s7,40(sp)
    800062ec:	f062                	sd	s8,32(sp)
    800062ee:	ec66                	sd	s9,24(sp)
    800062f0:	1880                	add	s0,sp,112
    800062f2:	8a2a                	mv	s4,a0
    800062f4:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800062f6:	00c52c83          	lw	s9,12(a0)
    800062fa:	001c9c9b          	sllw	s9,s9,0x1
    800062fe:	1c82                	sll	s9,s9,0x20
    80006300:	020cdc93          	srl	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006304:	0001f517          	auipc	a0,0x1f
    80006308:	9d450513          	add	a0,a0,-1580 # 80024cd8 <disk+0x128>
    8000630c:	ffffb097          	auipc	ra,0xffffb
    80006310:	92c080e7          	jalr	-1748(ra) # 80000c38 <acquire>
  for(int i = 0; i < 3; i++){
    80006314:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006316:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006318:	0001fb17          	auipc	s6,0x1f
    8000631c:	898b0b13          	add	s6,s6,-1896 # 80024bb0 <disk>
  for(int i = 0; i < 3; i++){
    80006320:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006322:	0001fc17          	auipc	s8,0x1f
    80006326:	9b6c0c13          	add	s8,s8,-1610 # 80024cd8 <disk+0x128>
    8000632a:	a0ad                	j	80006394 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    8000632c:	00fb0733          	add	a4,s6,a5
    80006330:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80006334:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006336:	0207c563          	bltz	a5,80006360 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000633a:	2905                	addw	s2,s2,1
    8000633c:	0611                	add	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000633e:	05590f63          	beq	s2,s5,8000639c <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80006342:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006344:	0001f717          	auipc	a4,0x1f
    80006348:	86c70713          	add	a4,a4,-1940 # 80024bb0 <disk>
    8000634c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000634e:	01874683          	lbu	a3,24(a4)
    80006352:	fee9                	bnez	a3,8000632c <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80006354:	2785                	addw	a5,a5,1
    80006356:	0705                	add	a4,a4,1
    80006358:	fe979be3          	bne	a5,s1,8000634e <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000635c:	57fd                	li	a5,-1
    8000635e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006360:	03205163          	blez	s2,80006382 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006364:	f9042503          	lw	a0,-112(s0)
    80006368:	00000097          	auipc	ra,0x0
    8000636c:	cc2080e7          	jalr	-830(ra) # 8000602a <free_desc>
      for(int j = 0; j < i; j++)
    80006370:	4785                	li	a5,1
    80006372:	0127d863          	bge	a5,s2,80006382 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006376:	f9442503          	lw	a0,-108(s0)
    8000637a:	00000097          	auipc	ra,0x0
    8000637e:	cb0080e7          	jalr	-848(ra) # 8000602a <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006382:	85e2                	mv	a1,s8
    80006384:	0001f517          	auipc	a0,0x1f
    80006388:	84450513          	add	a0,a0,-1980 # 80024bc8 <disk+0x18>
    8000638c:	ffffc097          	auipc	ra,0xffffc
    80006390:	d74080e7          	jalr	-652(ra) # 80002100 <sleep>
  for(int i = 0; i < 3; i++){
    80006394:	f9040613          	add	a2,s0,-112
    80006398:	894e                	mv	s2,s3
    8000639a:	b765                	j	80006342 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000639c:	f9042503          	lw	a0,-112(s0)
    800063a0:	00451693          	sll	a3,a0,0x4

  if(write)
    800063a4:	0001f797          	auipc	a5,0x1f
    800063a8:	80c78793          	add	a5,a5,-2036 # 80024bb0 <disk>
    800063ac:	00a50713          	add	a4,a0,10
    800063b0:	0712                	sll	a4,a4,0x4
    800063b2:	973e                	add	a4,a4,a5
    800063b4:	01703633          	snez	a2,s7
    800063b8:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800063ba:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800063be:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800063c2:	6398                	ld	a4,0(a5)
    800063c4:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800063c6:	0a868613          	add	a2,a3,168
    800063ca:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800063cc:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800063ce:	6390                	ld	a2,0(a5)
    800063d0:	00d605b3          	add	a1,a2,a3
    800063d4:	4741                	li	a4,16
    800063d6:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800063d8:	4805                	li	a6,1
    800063da:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800063de:	f9442703          	lw	a4,-108(s0)
    800063e2:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800063e6:	0712                	sll	a4,a4,0x4
    800063e8:	963a                	add	a2,a2,a4
    800063ea:	058a0593          	add	a1,s4,88
    800063ee:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800063f0:	0007b883          	ld	a7,0(a5)
    800063f4:	9746                	add	a4,a4,a7
    800063f6:	40000613          	li	a2,1024
    800063fa:	c710                	sw	a2,8(a4)
  if(write)
    800063fc:	001bb613          	seqz	a2,s7
    80006400:	0016161b          	sllw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006404:	00166613          	or	a2,a2,1
    80006408:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    8000640c:	f9842583          	lw	a1,-104(s0)
    80006410:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006414:	00250613          	add	a2,a0,2
    80006418:	0612                	sll	a2,a2,0x4
    8000641a:	963e                	add	a2,a2,a5
    8000641c:	577d                	li	a4,-1
    8000641e:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006422:	0592                	sll	a1,a1,0x4
    80006424:	98ae                	add	a7,a7,a1
    80006426:	03068713          	add	a4,a3,48
    8000642a:	973e                	add	a4,a4,a5
    8000642c:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006430:	6398                	ld	a4,0(a5)
    80006432:	972e                	add	a4,a4,a1
    80006434:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006438:	4689                	li	a3,2
    8000643a:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    8000643e:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006442:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80006446:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000644a:	6794                	ld	a3,8(a5)
    8000644c:	0026d703          	lhu	a4,2(a3)
    80006450:	8b1d                	and	a4,a4,7
    80006452:	0706                	sll	a4,a4,0x1
    80006454:	96ba                	add	a3,a3,a4
    80006456:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    8000645a:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000645e:	6798                	ld	a4,8(a5)
    80006460:	00275783          	lhu	a5,2(a4)
    80006464:	2785                	addw	a5,a5,1
    80006466:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000646a:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000646e:	100017b7          	lui	a5,0x10001
    80006472:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006476:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    8000647a:	0001f917          	auipc	s2,0x1f
    8000647e:	85e90913          	add	s2,s2,-1954 # 80024cd8 <disk+0x128>
  while(b->disk == 1) {
    80006482:	4485                	li	s1,1
    80006484:	01079c63          	bne	a5,a6,8000649c <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006488:	85ca                	mv	a1,s2
    8000648a:	8552                	mv	a0,s4
    8000648c:	ffffc097          	auipc	ra,0xffffc
    80006490:	c74080e7          	jalr	-908(ra) # 80002100 <sleep>
  while(b->disk == 1) {
    80006494:	004a2783          	lw	a5,4(s4)
    80006498:	fe9788e3          	beq	a5,s1,80006488 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    8000649c:	f9042903          	lw	s2,-112(s0)
    800064a0:	00290713          	add	a4,s2,2
    800064a4:	0712                	sll	a4,a4,0x4
    800064a6:	0001e797          	auipc	a5,0x1e
    800064aa:	70a78793          	add	a5,a5,1802 # 80024bb0 <disk>
    800064ae:	97ba                	add	a5,a5,a4
    800064b0:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800064b4:	0001e997          	auipc	s3,0x1e
    800064b8:	6fc98993          	add	s3,s3,1788 # 80024bb0 <disk>
    800064bc:	00491713          	sll	a4,s2,0x4
    800064c0:	0009b783          	ld	a5,0(s3)
    800064c4:	97ba                	add	a5,a5,a4
    800064c6:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800064ca:	854a                	mv	a0,s2
    800064cc:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800064d0:	00000097          	auipc	ra,0x0
    800064d4:	b5a080e7          	jalr	-1190(ra) # 8000602a <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800064d8:	8885                	and	s1,s1,1
    800064da:	f0ed                	bnez	s1,800064bc <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800064dc:	0001e517          	auipc	a0,0x1e
    800064e0:	7fc50513          	add	a0,a0,2044 # 80024cd8 <disk+0x128>
    800064e4:	ffffb097          	auipc	ra,0xffffb
    800064e8:	808080e7          	jalr	-2040(ra) # 80000cec <release>
}
    800064ec:	70a6                	ld	ra,104(sp)
    800064ee:	7406                	ld	s0,96(sp)
    800064f0:	64e6                	ld	s1,88(sp)
    800064f2:	6946                	ld	s2,80(sp)
    800064f4:	69a6                	ld	s3,72(sp)
    800064f6:	6a06                	ld	s4,64(sp)
    800064f8:	7ae2                	ld	s5,56(sp)
    800064fa:	7b42                	ld	s6,48(sp)
    800064fc:	7ba2                	ld	s7,40(sp)
    800064fe:	7c02                	ld	s8,32(sp)
    80006500:	6ce2                	ld	s9,24(sp)
    80006502:	6165                	add	sp,sp,112
    80006504:	8082                	ret

0000000080006506 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006506:	1101                	add	sp,sp,-32
    80006508:	ec06                	sd	ra,24(sp)
    8000650a:	e822                	sd	s0,16(sp)
    8000650c:	e426                	sd	s1,8(sp)
    8000650e:	1000                	add	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006510:	0001e497          	auipc	s1,0x1e
    80006514:	6a048493          	add	s1,s1,1696 # 80024bb0 <disk>
    80006518:	0001e517          	auipc	a0,0x1e
    8000651c:	7c050513          	add	a0,a0,1984 # 80024cd8 <disk+0x128>
    80006520:	ffffa097          	auipc	ra,0xffffa
    80006524:	718080e7          	jalr	1816(ra) # 80000c38 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006528:	100017b7          	lui	a5,0x10001
    8000652c:	53b8                	lw	a4,96(a5)
    8000652e:	8b0d                	and	a4,a4,3
    80006530:	100017b7          	lui	a5,0x10001
    80006534:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80006536:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    8000653a:	689c                	ld	a5,16(s1)
    8000653c:	0204d703          	lhu	a4,32(s1)
    80006540:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006544:	04f70863          	beq	a4,a5,80006594 <virtio_disk_intr+0x8e>
    __sync_synchronize();
    80006548:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000654c:	6898                	ld	a4,16(s1)
    8000654e:	0204d783          	lhu	a5,32(s1)
    80006552:	8b9d                	and	a5,a5,7
    80006554:	078e                	sll	a5,a5,0x3
    80006556:	97ba                	add	a5,a5,a4
    80006558:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000655a:	00278713          	add	a4,a5,2
    8000655e:	0712                	sll	a4,a4,0x4
    80006560:	9726                	add	a4,a4,s1
    80006562:	01074703          	lbu	a4,16(a4)
    80006566:	e721                	bnez	a4,800065ae <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006568:	0789                	add	a5,a5,2
    8000656a:	0792                	sll	a5,a5,0x4
    8000656c:	97a6                	add	a5,a5,s1
    8000656e:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006570:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006574:	ffffc097          	auipc	ra,0xffffc
    80006578:	bf6080e7          	jalr	-1034(ra) # 8000216a <wakeup>

    disk.used_idx += 1;
    8000657c:	0204d783          	lhu	a5,32(s1)
    80006580:	2785                	addw	a5,a5,1
    80006582:	17c2                	sll	a5,a5,0x30
    80006584:	93c1                	srl	a5,a5,0x30
    80006586:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000658a:	6898                	ld	a4,16(s1)
    8000658c:	00275703          	lhu	a4,2(a4)
    80006590:	faf71ce3          	bne	a4,a5,80006548 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006594:	0001e517          	auipc	a0,0x1e
    80006598:	74450513          	add	a0,a0,1860 # 80024cd8 <disk+0x128>
    8000659c:	ffffa097          	auipc	ra,0xffffa
    800065a0:	750080e7          	jalr	1872(ra) # 80000cec <release>
}
    800065a4:	60e2                	ld	ra,24(sp)
    800065a6:	6442                	ld	s0,16(sp)
    800065a8:	64a2                	ld	s1,8(sp)
    800065aa:	6105                	add	sp,sp,32
    800065ac:	8082                	ret
      panic("virtio_disk_intr status");
    800065ae:	00002517          	auipc	a0,0x2
    800065b2:	2b250513          	add	a0,a0,690 # 80008860 <states.0+0x358>
    800065b6:	ffffa097          	auipc	ra,0xffffa
    800065ba:	faa080e7          	jalr	-86(ra) # 80000560 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	sll	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	sll	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
