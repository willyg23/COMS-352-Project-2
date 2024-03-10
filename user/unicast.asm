
user/_unicast:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <panic>:
struct msg_t {
    int target; // Add target child ID
    char content[MAX_MSG_SIZE];
};

void panic(char *s) {
   0:	1141                	add	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	add	s0,sp,16
   8:	862a                	mv	a2,a0
    fprintf(2, "%s\n", s);
   a:	00001597          	auipc	a1,0x1
   e:	a0658593          	add	a1,a1,-1530 # a10 <malloc+0x10a>
  12:	4509                	li	a0,2
  14:	00001097          	auipc	ra,0x1
  18:	80c080e7          	jalr	-2036(ra) # 820 <fprintf>
    exit(1);
  1c:	4505                	li	a0,1
  1e:	00000097          	auipc	ra,0x0
  22:	4b0080e7          	jalr	1200(ra) # 4ce <exit>

0000000000000026 <fork1>:
}

int fork1(void) {
  26:	1141                	add	sp,sp,-16
  28:	e406                	sd	ra,8(sp)
  2a:	e022                	sd	s0,0(sp)
  2c:	0800                	add	s0,sp,16
    int pid = fork();
  2e:	00000097          	auipc	ra,0x0
  32:	498080e7          	jalr	1176(ra) # 4c6 <fork>
    if(pid == -1)
  36:	57fd                	li	a5,-1
  38:	00f50663          	beq	a0,a5,44 <fork1+0x1e>
        panic("fork");
    return pid;
}
  3c:	60a2                	ld	ra,8(sp)
  3e:	6402                	ld	s0,0(sp)
  40:	0141                	add	sp,sp,16
  42:	8082                	ret
        panic("fork");
  44:	00001517          	auipc	a0,0x1
  48:	9d450513          	add	a0,a0,-1580 # a18 <malloc+0x112>
  4c:	00000097          	auipc	ra,0x0
  50:	fb4080e7          	jalr	-76(ra) # 0 <panic>

0000000000000054 <pipe1>:

void pipe1(int fd[2]) {
  54:	1141                	add	sp,sp,-16
  56:	e406                	sd	ra,8(sp)
  58:	e022                	sd	s0,0(sp)
  5a:	0800                	add	s0,sp,16
    if(pipe(fd) < 0) {
  5c:	00000097          	auipc	ra,0x0
  60:	482080e7          	jalr	1154(ra) # 4de <pipe>
  64:	00054663          	bltz	a0,70 <pipe1+0x1c>
        panic("Fail to create a pipe.");
    }
}
  68:	60a2                	ld	ra,8(sp)
  6a:	6402                	ld	s0,0(sp)
  6c:	0141                	add	sp,sp,16
  6e:	8082                	ret
        panic("Fail to create a pipe.");
  70:	00001517          	auipc	a0,0x1
  74:	9b050513          	add	a0,a0,-1616 # a20 <malloc+0x11a>
  78:	00000097          	auipc	ra,0x0
  7c:	f88080e7          	jalr	-120(ra) # 0 <panic>

0000000000000080 <main>:

int main(int argc, char *argv[]) {
  80:	710d                	add	sp,sp,-352
  82:	ee86                	sd	ra,344(sp)
  84:	eaa2                	sd	s0,336(sp)
  86:	1280                	add	s0,sp,352
    if(argc < 4) {
  88:	478d                	li	a5,3
  8a:	00a7ce63          	blt	a5,a0,a6 <main+0x26>
  8e:	e6a6                	sd	s1,328(sp)
  90:	e2ca                	sd	s2,320(sp)
  92:	fe4e                	sd	s3,312(sp)
  94:	fa52                	sd	s4,304(sp)
        panic("Usage: unicast <num_of_children> <target_child> <msg>");
  96:	00001517          	auipc	a0,0x1
  9a:	9a250513          	add	a0,a0,-1630 # a38 <malloc+0x132>
  9e:	00000097          	auipc	ra,0x0
  a2:	f62080e7          	jalr	-158(ra) # 0 <panic>
  a6:	e6a6                	sd	s1,328(sp)
  a8:	e2ca                	sd	s2,320(sp)
  aa:	fe4e                	sd	s3,312(sp)
  ac:	fa52                	sd	s4,304(sp)
  ae:	84ae                	mv	s1,a1
    }

    int numChildren = atoi(argv[1]);
  b0:	6588                	ld	a0,8(a1)
  b2:	00000097          	auipc	ra,0x0
  b6:	322080e7          	jalr	802(ra) # 3d4 <atoi>
  ba:	892a                	mv	s2,a0
    int targetChild = atoi(argv[2]);
  bc:	6888                	ld	a0,16(s1)
  be:	00000097          	auipc	ra,0x0
  c2:	316080e7          	jalr	790(ra) # 3d4 <atoi>
  c6:	8a2a                	mv	s4,a0
    struct msg_t msg;
    msg.target = targetChild; // Set target child ID
  c8:	eca42423          	sw	a0,-312(s0)
    strcpy(msg.content, argv[3]);
  cc:	6c8c                	ld	a1,24(s1)
  ce:	ecc40513          	add	a0,s0,-308
  d2:	00000097          	auipc	ra,0x0
  d6:	190080e7          	jalr	400(ra) # 262 <strcpy>

    int channelToChildren[2], channelFromChild[2];
    pipe1(channelToChildren);
  da:	ec040513          	add	a0,s0,-320
  de:	00000097          	auipc	ra,0x0
  e2:	f76080e7          	jalr	-138(ra) # 54 <pipe1>
    pipe1(channelFromChild);
  e6:	eb840513          	add	a0,s0,-328
  ea:	00000097          	auipc	ra,0x0
  ee:	f6a080e7          	jalr	-150(ra) # 54 <pipe1>

    for(int i = 0; i < numChildren; i++) {
  f2:	03205a63          	blez	s2,126 <main+0xa6>
  f6:	4481                	li	s1,0
                printf("Child %d: write the msg back to pipe.\n", i);
                write(channelToChildren[1], &msg, sizeof(msg)); // Pass the message along
            }
            exit(0);
        } else {
            printf("Parent: creates child process with id: %d\n", i);
  f8:	00001997          	auipc	s3,0x1
  fc:	a3898993          	add	s3,s3,-1480 # b30 <malloc+0x22a>
        int retFork = fork1();
 100:	00000097          	auipc	ra,0x0
 104:	f26080e7          	jalr	-218(ra) # 26 <fork1>
        if(retFork == 0) { // Child process
 108:	cd25                	beqz	a0,180 <main+0x100>
            printf("Parent: creates child process with id: %d\n", i);
 10a:	85a6                	mv	a1,s1
 10c:	854e                	mv	a0,s3
 10e:	00000097          	auipc	ra,0x0
 112:	740080e7          	jalr	1856(ra) # 84e <printf>
        }
        sleep(1); // Ensure orderly startup
 116:	4505                	li	a0,1
 118:	00000097          	auipc	ra,0x0
 11c:	446080e7          	jalr	1094(ra) # 55e <sleep>
    for(int i = 0; i < numChildren; i++) {
 120:	2485                	addw	s1,s1,1
 122:	fc991fe3          	bne	s2,s1,100 <main+0x80>
    }

    // Parent sends message to the first child
    write(channelToChildren[1], &msg, sizeof(msg));
 126:	10400613          	li	a2,260
 12a:	ec840593          	add	a1,s0,-312
 12e:	ec442503          	lw	a0,-316(s0)
 132:	00000097          	auipc	ra,0x0
 136:	3bc080e7          	jalr	956(ra) # 4ee <write>
    printf("Parent sends to Child %d: %s\n", targetChild, msg.content);
 13a:	ecc40613          	add	a2,s0,-308
 13e:	85d2                	mv	a1,s4
 140:	00001517          	auipc	a0,0x1
 144:	a2050513          	add	a0,a0,-1504 # b60 <malloc+0x25a>
 148:	00000097          	auipc	ra,0x0
 14c:	706080e7          	jalr	1798(ra) # 84e <printf>

    char recvBuf[20]; // Buffer for acknowledgment
    read(channelFromChild[0], &recvBuf, sizeof(recvBuf));
 150:	4651                	li	a2,20
 152:	ea040593          	add	a1,s0,-352
 156:	eb842503          	lw	a0,-328(s0)
 15a:	00000097          	auipc	ra,0x0
 15e:	38c080e7          	jalr	908(ra) # 4e6 <read>
    printf("Parent receives: %s\n", recvBuf);
 162:	ea040593          	add	a1,s0,-352
 166:	00001517          	auipc	a0,0x1
 16a:	a1a50513          	add	a0,a0,-1510 # b80 <malloc+0x27a>
 16e:	00000097          	auipc	ra,0x0
 172:	6e0080e7          	jalr	1760(ra) # 84e <printf>

    exit(0);
 176:	4501                	li	a0,0
 178:	00000097          	auipc	ra,0x0
 17c:	356080e7          	jalr	854(ra) # 4ce <exit>
            printf("Child %d: start!\n", i);
 180:	85a6                	mv	a1,s1
 182:	00001517          	auipc	a0,0x1
 186:	8ee50513          	add	a0,a0,-1810 # a70 <malloc+0x16a>
 18a:	00000097          	auipc	ra,0x0
 18e:	6c4080e7          	jalr	1732(ra) # 84e <printf>
            read(channelToChildren[0], &msg, sizeof(msg));
 192:	10400613          	li	a2,260
 196:	ec840593          	add	a1,s0,-312
 19a:	ec042503          	lw	a0,-320(s0)
 19e:	00000097          	auipc	ra,0x0
 1a2:	348080e7          	jalr	840(ra) # 4e6 <read>
            if(i == msg.target) {
 1a6:	ec842683          	lw	a3,-312(s0)
 1aa:	04968e63          	beq	a3,s1,206 <main+0x186>
                printf("Child %d: get msg (%s) to Child %d\n", i, msg.content, msg.target);
 1ae:	ecc40613          	add	a2,s0,-308
 1b2:	85a6                	mv	a1,s1
 1b4:	00001517          	auipc	a0,0x1
 1b8:	8d450513          	add	a0,a0,-1836 # a88 <malloc+0x182>
 1bc:	00000097          	auipc	ra,0x0
 1c0:	692080e7          	jalr	1682(ra) # 84e <printf>
                printf("Child %d: the msg is not for me.\n", i);
 1c4:	85a6                	mv	a1,s1
 1c6:	00001517          	auipc	a0,0x1
 1ca:	91a50513          	add	a0,a0,-1766 # ae0 <malloc+0x1da>
 1ce:	00000097          	auipc	ra,0x0
 1d2:	680080e7          	jalr	1664(ra) # 84e <printf>
                printf("Child %d: write the msg back to pipe.\n", i);
 1d6:	85a6                	mv	a1,s1
 1d8:	00001517          	auipc	a0,0x1
 1dc:	93050513          	add	a0,a0,-1744 # b08 <malloc+0x202>
 1e0:	00000097          	auipc	ra,0x0
 1e4:	66e080e7          	jalr	1646(ra) # 84e <printf>
                write(channelToChildren[1], &msg, sizeof(msg)); // Pass the message along
 1e8:	10400613          	li	a2,260
 1ec:	ec840593          	add	a1,s0,-312
 1f0:	ec442503          	lw	a0,-316(s0)
 1f4:	00000097          	auipc	ra,0x0
 1f8:	2fa080e7          	jalr	762(ra) # 4ee <write>
            exit(0);
 1fc:	4501                	li	a0,0
 1fe:	00000097          	auipc	ra,0x0
 202:	2d0080e7          	jalr	720(ra) # 4ce <exit>
                printf("Child %d: get msg (%s) to Child %d\n", i, msg.content, msg.target);
 206:	86a6                	mv	a3,s1
 208:	ecc40613          	add	a2,s0,-308
 20c:	85a6                	mv	a1,s1
 20e:	00001517          	auipc	a0,0x1
 212:	87a50513          	add	a0,a0,-1926 # a88 <malloc+0x182>
 216:	00000097          	auipc	ra,0x0
 21a:	638080e7          	jalr	1592(ra) # 84e <printf>
                printf("Child %d: the msg is for me.\n", i);
 21e:	85a6                	mv	a1,s1
 220:	00001517          	auipc	a0,0x1
 224:	89050513          	add	a0,a0,-1904 # ab0 <malloc+0x1aa>
 228:	00000097          	auipc	ra,0x0
 22c:	626080e7          	jalr	1574(ra) # 84e <printf>
                write(channelFromChild[1], "received!", 10);
 230:	4629                	li	a2,10
 232:	00001597          	auipc	a1,0x1
 236:	89e58593          	add	a1,a1,-1890 # ad0 <malloc+0x1ca>
 23a:	ebc42503          	lw	a0,-324(s0)
 23e:	00000097          	auipc	ra,0x0
 242:	2b0080e7          	jalr	688(ra) # 4ee <write>
 246:	bf5d                	j	1fc <main+0x17c>

0000000000000248 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 248:	1141                	add	sp,sp,-16
 24a:	e406                	sd	ra,8(sp)
 24c:	e022                	sd	s0,0(sp)
 24e:	0800                	add	s0,sp,16
  extern int main();
  main();
 250:	00000097          	auipc	ra,0x0
 254:	e30080e7          	jalr	-464(ra) # 80 <main>
  exit(0);
 258:	4501                	li	a0,0
 25a:	00000097          	auipc	ra,0x0
 25e:	274080e7          	jalr	628(ra) # 4ce <exit>

0000000000000262 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 262:	1141                	add	sp,sp,-16
 264:	e422                	sd	s0,8(sp)
 266:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 268:	87aa                	mv	a5,a0
 26a:	0585                	add	a1,a1,1
 26c:	0785                	add	a5,a5,1
 26e:	fff5c703          	lbu	a4,-1(a1)
 272:	fee78fa3          	sb	a4,-1(a5)
 276:	fb75                	bnez	a4,26a <strcpy+0x8>
    ;
  return os;
}
 278:	6422                	ld	s0,8(sp)
 27a:	0141                	add	sp,sp,16
 27c:	8082                	ret

000000000000027e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 27e:	1141                	add	sp,sp,-16
 280:	e422                	sd	s0,8(sp)
 282:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 284:	00054783          	lbu	a5,0(a0)
 288:	cb91                	beqz	a5,29c <strcmp+0x1e>
 28a:	0005c703          	lbu	a4,0(a1)
 28e:	00f71763          	bne	a4,a5,29c <strcmp+0x1e>
    p++, q++;
 292:	0505                	add	a0,a0,1
 294:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 296:	00054783          	lbu	a5,0(a0)
 29a:	fbe5                	bnez	a5,28a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 29c:	0005c503          	lbu	a0,0(a1)
}
 2a0:	40a7853b          	subw	a0,a5,a0
 2a4:	6422                	ld	s0,8(sp)
 2a6:	0141                	add	sp,sp,16
 2a8:	8082                	ret

00000000000002aa <strlen>:

uint
strlen(const char *s)
{
 2aa:	1141                	add	sp,sp,-16
 2ac:	e422                	sd	s0,8(sp)
 2ae:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2b0:	00054783          	lbu	a5,0(a0)
 2b4:	cf91                	beqz	a5,2d0 <strlen+0x26>
 2b6:	0505                	add	a0,a0,1
 2b8:	87aa                	mv	a5,a0
 2ba:	86be                	mv	a3,a5
 2bc:	0785                	add	a5,a5,1
 2be:	fff7c703          	lbu	a4,-1(a5)
 2c2:	ff65                	bnez	a4,2ba <strlen+0x10>
 2c4:	40a6853b          	subw	a0,a3,a0
 2c8:	2505                	addw	a0,a0,1
    ;
  return n;
}
 2ca:	6422                	ld	s0,8(sp)
 2cc:	0141                	add	sp,sp,16
 2ce:	8082                	ret
  for(n = 0; s[n]; n++)
 2d0:	4501                	li	a0,0
 2d2:	bfe5                	j	2ca <strlen+0x20>

00000000000002d4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2d4:	1141                	add	sp,sp,-16
 2d6:	e422                	sd	s0,8(sp)
 2d8:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2da:	ca19                	beqz	a2,2f0 <memset+0x1c>
 2dc:	87aa                	mv	a5,a0
 2de:	1602                	sll	a2,a2,0x20
 2e0:	9201                	srl	a2,a2,0x20
 2e2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2e6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2ea:	0785                	add	a5,a5,1
 2ec:	fee79de3          	bne	a5,a4,2e6 <memset+0x12>
  }
  return dst;
}
 2f0:	6422                	ld	s0,8(sp)
 2f2:	0141                	add	sp,sp,16
 2f4:	8082                	ret

00000000000002f6 <strchr>:

char*
strchr(const char *s, char c)
{
 2f6:	1141                	add	sp,sp,-16
 2f8:	e422                	sd	s0,8(sp)
 2fa:	0800                	add	s0,sp,16
  for(; *s; s++)
 2fc:	00054783          	lbu	a5,0(a0)
 300:	cb99                	beqz	a5,316 <strchr+0x20>
    if(*s == c)
 302:	00f58763          	beq	a1,a5,310 <strchr+0x1a>
  for(; *s; s++)
 306:	0505                	add	a0,a0,1
 308:	00054783          	lbu	a5,0(a0)
 30c:	fbfd                	bnez	a5,302 <strchr+0xc>
      return (char*)s;
  return 0;
 30e:	4501                	li	a0,0
}
 310:	6422                	ld	s0,8(sp)
 312:	0141                	add	sp,sp,16
 314:	8082                	ret
  return 0;
 316:	4501                	li	a0,0
 318:	bfe5                	j	310 <strchr+0x1a>

000000000000031a <gets>:

char*
gets(char *buf, int max)
{
 31a:	711d                	add	sp,sp,-96
 31c:	ec86                	sd	ra,88(sp)
 31e:	e8a2                	sd	s0,80(sp)
 320:	e4a6                	sd	s1,72(sp)
 322:	e0ca                	sd	s2,64(sp)
 324:	fc4e                	sd	s3,56(sp)
 326:	f852                	sd	s4,48(sp)
 328:	f456                	sd	s5,40(sp)
 32a:	f05a                	sd	s6,32(sp)
 32c:	ec5e                	sd	s7,24(sp)
 32e:	1080                	add	s0,sp,96
 330:	8baa                	mv	s7,a0
 332:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 334:	892a                	mv	s2,a0
 336:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 338:	4aa9                	li	s5,10
 33a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 33c:	89a6                	mv	s3,s1
 33e:	2485                	addw	s1,s1,1
 340:	0344d863          	bge	s1,s4,370 <gets+0x56>
    cc = read(0, &c, 1);
 344:	4605                	li	a2,1
 346:	faf40593          	add	a1,s0,-81
 34a:	4501                	li	a0,0
 34c:	00000097          	auipc	ra,0x0
 350:	19a080e7          	jalr	410(ra) # 4e6 <read>
    if(cc < 1)
 354:	00a05e63          	blez	a0,370 <gets+0x56>
    buf[i++] = c;
 358:	faf44783          	lbu	a5,-81(s0)
 35c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 360:	01578763          	beq	a5,s5,36e <gets+0x54>
 364:	0905                	add	s2,s2,1
 366:	fd679be3          	bne	a5,s6,33c <gets+0x22>
    buf[i++] = c;
 36a:	89a6                	mv	s3,s1
 36c:	a011                	j	370 <gets+0x56>
 36e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 370:	99de                	add	s3,s3,s7
 372:	00098023          	sb	zero,0(s3)
  return buf;
}
 376:	855e                	mv	a0,s7
 378:	60e6                	ld	ra,88(sp)
 37a:	6446                	ld	s0,80(sp)
 37c:	64a6                	ld	s1,72(sp)
 37e:	6906                	ld	s2,64(sp)
 380:	79e2                	ld	s3,56(sp)
 382:	7a42                	ld	s4,48(sp)
 384:	7aa2                	ld	s5,40(sp)
 386:	7b02                	ld	s6,32(sp)
 388:	6be2                	ld	s7,24(sp)
 38a:	6125                	add	sp,sp,96
 38c:	8082                	ret

000000000000038e <stat>:

int
stat(const char *n, struct stat *st)
{
 38e:	1101                	add	sp,sp,-32
 390:	ec06                	sd	ra,24(sp)
 392:	e822                	sd	s0,16(sp)
 394:	e04a                	sd	s2,0(sp)
 396:	1000                	add	s0,sp,32
 398:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 39a:	4581                	li	a1,0
 39c:	00000097          	auipc	ra,0x0
 3a0:	172080e7          	jalr	370(ra) # 50e <open>
  if(fd < 0)
 3a4:	02054663          	bltz	a0,3d0 <stat+0x42>
 3a8:	e426                	sd	s1,8(sp)
 3aa:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3ac:	85ca                	mv	a1,s2
 3ae:	00000097          	auipc	ra,0x0
 3b2:	178080e7          	jalr	376(ra) # 526 <fstat>
 3b6:	892a                	mv	s2,a0
  close(fd);
 3b8:	8526                	mv	a0,s1
 3ba:	00000097          	auipc	ra,0x0
 3be:	13c080e7          	jalr	316(ra) # 4f6 <close>
  return r;
 3c2:	64a2                	ld	s1,8(sp)
}
 3c4:	854a                	mv	a0,s2
 3c6:	60e2                	ld	ra,24(sp)
 3c8:	6442                	ld	s0,16(sp)
 3ca:	6902                	ld	s2,0(sp)
 3cc:	6105                	add	sp,sp,32
 3ce:	8082                	ret
    return -1;
 3d0:	597d                	li	s2,-1
 3d2:	bfcd                	j	3c4 <stat+0x36>

00000000000003d4 <atoi>:

int
atoi(const char *s)
{
 3d4:	1141                	add	sp,sp,-16
 3d6:	e422                	sd	s0,8(sp)
 3d8:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3da:	00054683          	lbu	a3,0(a0)
 3de:	fd06879b          	addw	a5,a3,-48
 3e2:	0ff7f793          	zext.b	a5,a5
 3e6:	4625                	li	a2,9
 3e8:	02f66863          	bltu	a2,a5,418 <atoi+0x44>
 3ec:	872a                	mv	a4,a0
  n = 0;
 3ee:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3f0:	0705                	add	a4,a4,1
 3f2:	0025179b          	sllw	a5,a0,0x2
 3f6:	9fa9                	addw	a5,a5,a0
 3f8:	0017979b          	sllw	a5,a5,0x1
 3fc:	9fb5                	addw	a5,a5,a3
 3fe:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 402:	00074683          	lbu	a3,0(a4)
 406:	fd06879b          	addw	a5,a3,-48
 40a:	0ff7f793          	zext.b	a5,a5
 40e:	fef671e3          	bgeu	a2,a5,3f0 <atoi+0x1c>
  return n;
}
 412:	6422                	ld	s0,8(sp)
 414:	0141                	add	sp,sp,16
 416:	8082                	ret
  n = 0;
 418:	4501                	li	a0,0
 41a:	bfe5                	j	412 <atoi+0x3e>

000000000000041c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 41c:	1141                	add	sp,sp,-16
 41e:	e422                	sd	s0,8(sp)
 420:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 422:	02b57463          	bgeu	a0,a1,44a <memmove+0x2e>
    while(n-- > 0)
 426:	00c05f63          	blez	a2,444 <memmove+0x28>
 42a:	1602                	sll	a2,a2,0x20
 42c:	9201                	srl	a2,a2,0x20
 42e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 432:	872a                	mv	a4,a0
      *dst++ = *src++;
 434:	0585                	add	a1,a1,1
 436:	0705                	add	a4,a4,1
 438:	fff5c683          	lbu	a3,-1(a1)
 43c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 440:	fef71ae3          	bne	a4,a5,434 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 444:	6422                	ld	s0,8(sp)
 446:	0141                	add	sp,sp,16
 448:	8082                	ret
    dst += n;
 44a:	00c50733          	add	a4,a0,a2
    src += n;
 44e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 450:	fec05ae3          	blez	a2,444 <memmove+0x28>
 454:	fff6079b          	addw	a5,a2,-1
 458:	1782                	sll	a5,a5,0x20
 45a:	9381                	srl	a5,a5,0x20
 45c:	fff7c793          	not	a5,a5
 460:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 462:	15fd                	add	a1,a1,-1
 464:	177d                	add	a4,a4,-1
 466:	0005c683          	lbu	a3,0(a1)
 46a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 46e:	fee79ae3          	bne	a5,a4,462 <memmove+0x46>
 472:	bfc9                	j	444 <memmove+0x28>

0000000000000474 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 474:	1141                	add	sp,sp,-16
 476:	e422                	sd	s0,8(sp)
 478:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 47a:	ca05                	beqz	a2,4aa <memcmp+0x36>
 47c:	fff6069b          	addw	a3,a2,-1
 480:	1682                	sll	a3,a3,0x20
 482:	9281                	srl	a3,a3,0x20
 484:	0685                	add	a3,a3,1
 486:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 488:	00054783          	lbu	a5,0(a0)
 48c:	0005c703          	lbu	a4,0(a1)
 490:	00e79863          	bne	a5,a4,4a0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 494:	0505                	add	a0,a0,1
    p2++;
 496:	0585                	add	a1,a1,1
  while (n-- > 0) {
 498:	fed518e3          	bne	a0,a3,488 <memcmp+0x14>
  }
  return 0;
 49c:	4501                	li	a0,0
 49e:	a019                	j	4a4 <memcmp+0x30>
      return *p1 - *p2;
 4a0:	40e7853b          	subw	a0,a5,a4
}
 4a4:	6422                	ld	s0,8(sp)
 4a6:	0141                	add	sp,sp,16
 4a8:	8082                	ret
  return 0;
 4aa:	4501                	li	a0,0
 4ac:	bfe5                	j	4a4 <memcmp+0x30>

00000000000004ae <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4ae:	1141                	add	sp,sp,-16
 4b0:	e406                	sd	ra,8(sp)
 4b2:	e022                	sd	s0,0(sp)
 4b4:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 4b6:	00000097          	auipc	ra,0x0
 4ba:	f66080e7          	jalr	-154(ra) # 41c <memmove>
}
 4be:	60a2                	ld	ra,8(sp)
 4c0:	6402                	ld	s0,0(sp)
 4c2:	0141                	add	sp,sp,16
 4c4:	8082                	ret

00000000000004c6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4c6:	4885                	li	a7,1
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <exit>:
.global exit
exit:
 li a7, SYS_exit
 4ce:	4889                	li	a7,2
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4d6:	488d                	li	a7,3
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4de:	4891                	li	a7,4
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <read>:
.global read
read:
 li a7, SYS_read
 4e6:	4895                	li	a7,5
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <write>:
.global write
write:
 li a7, SYS_write
 4ee:	48c1                	li	a7,16
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <close>:
.global close
close:
 li a7, SYS_close
 4f6:	48d5                	li	a7,21
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <kill>:
.global kill
kill:
 li a7, SYS_kill
 4fe:	4899                	li	a7,6
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <exec>:
.global exec
exec:
 li a7, SYS_exec
 506:	489d                	li	a7,7
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <open>:
.global open
open:
 li a7, SYS_open
 50e:	48bd                	li	a7,15
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 516:	48c5                	li	a7,17
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 51e:	48c9                	li	a7,18
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 526:	48a1                	li	a7,8
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <link>:
.global link
link:
 li a7, SYS_link
 52e:	48cd                	li	a7,19
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 536:	48d1                	li	a7,20
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 53e:	48a5                	li	a7,9
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <dup>:
.global dup
dup:
 li a7, SYS_dup
 546:	48a9                	li	a7,10
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 54e:	48ad                	li	a7,11
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 556:	48b1                	li	a7,12
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 55e:	48b5                	li	a7,13
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 566:	48b9                	li	a7,14
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 56e:	48d9                	li	a7,22
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <ps>:
.global ps
ps:
 li a7, SYS_ps
 576:	48dd                	li	a7,23
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <getschedhistory>:
.global getschedhistory
getschedhistory:
 li a7, SYS_getschedhistory
 57e:	48e1                	li	a7,24
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 586:	1101                	add	sp,sp,-32
 588:	ec06                	sd	ra,24(sp)
 58a:	e822                	sd	s0,16(sp)
 58c:	1000                	add	s0,sp,32
 58e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 592:	4605                	li	a2,1
 594:	fef40593          	add	a1,s0,-17
 598:	00000097          	auipc	ra,0x0
 59c:	f56080e7          	jalr	-170(ra) # 4ee <write>
}
 5a0:	60e2                	ld	ra,24(sp)
 5a2:	6442                	ld	s0,16(sp)
 5a4:	6105                	add	sp,sp,32
 5a6:	8082                	ret

00000000000005a8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5a8:	7139                	add	sp,sp,-64
 5aa:	fc06                	sd	ra,56(sp)
 5ac:	f822                	sd	s0,48(sp)
 5ae:	f426                	sd	s1,40(sp)
 5b0:	0080                	add	s0,sp,64
 5b2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5b4:	c299                	beqz	a3,5ba <printint+0x12>
 5b6:	0805cb63          	bltz	a1,64c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5ba:	2581                	sext.w	a1,a1
  neg = 0;
 5bc:	4881                	li	a7,0
 5be:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 5c2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5c4:	2601                	sext.w	a2,a2
 5c6:	00000517          	auipc	a0,0x0
 5ca:	63250513          	add	a0,a0,1586 # bf8 <digits>
 5ce:	883a                	mv	a6,a4
 5d0:	2705                	addw	a4,a4,1
 5d2:	02c5f7bb          	remuw	a5,a1,a2
 5d6:	1782                	sll	a5,a5,0x20
 5d8:	9381                	srl	a5,a5,0x20
 5da:	97aa                	add	a5,a5,a0
 5dc:	0007c783          	lbu	a5,0(a5)
 5e0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5e4:	0005879b          	sext.w	a5,a1
 5e8:	02c5d5bb          	divuw	a1,a1,a2
 5ec:	0685                	add	a3,a3,1
 5ee:	fec7f0e3          	bgeu	a5,a2,5ce <printint+0x26>
  if(neg)
 5f2:	00088c63          	beqz	a7,60a <printint+0x62>
    buf[i++] = '-';
 5f6:	fd070793          	add	a5,a4,-48
 5fa:	00878733          	add	a4,a5,s0
 5fe:	02d00793          	li	a5,45
 602:	fef70823          	sb	a5,-16(a4)
 606:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 60a:	02e05c63          	blez	a4,642 <printint+0x9a>
 60e:	f04a                	sd	s2,32(sp)
 610:	ec4e                	sd	s3,24(sp)
 612:	fc040793          	add	a5,s0,-64
 616:	00e78933          	add	s2,a5,a4
 61a:	fff78993          	add	s3,a5,-1
 61e:	99ba                	add	s3,s3,a4
 620:	377d                	addw	a4,a4,-1
 622:	1702                	sll	a4,a4,0x20
 624:	9301                	srl	a4,a4,0x20
 626:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 62a:	fff94583          	lbu	a1,-1(s2)
 62e:	8526                	mv	a0,s1
 630:	00000097          	auipc	ra,0x0
 634:	f56080e7          	jalr	-170(ra) # 586 <putc>
  while(--i >= 0)
 638:	197d                	add	s2,s2,-1
 63a:	ff3918e3          	bne	s2,s3,62a <printint+0x82>
 63e:	7902                	ld	s2,32(sp)
 640:	69e2                	ld	s3,24(sp)
}
 642:	70e2                	ld	ra,56(sp)
 644:	7442                	ld	s0,48(sp)
 646:	74a2                	ld	s1,40(sp)
 648:	6121                	add	sp,sp,64
 64a:	8082                	ret
    x = -xx;
 64c:	40b005bb          	negw	a1,a1
    neg = 1;
 650:	4885                	li	a7,1
    x = -xx;
 652:	b7b5                	j	5be <printint+0x16>

0000000000000654 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 654:	715d                	add	sp,sp,-80
 656:	e486                	sd	ra,72(sp)
 658:	e0a2                	sd	s0,64(sp)
 65a:	f84a                	sd	s2,48(sp)
 65c:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 65e:	0005c903          	lbu	s2,0(a1)
 662:	1a090a63          	beqz	s2,816 <vprintf+0x1c2>
 666:	fc26                	sd	s1,56(sp)
 668:	f44e                	sd	s3,40(sp)
 66a:	f052                	sd	s4,32(sp)
 66c:	ec56                	sd	s5,24(sp)
 66e:	e85a                	sd	s6,16(sp)
 670:	e45e                	sd	s7,8(sp)
 672:	8aaa                	mv	s5,a0
 674:	8bb2                	mv	s7,a2
 676:	00158493          	add	s1,a1,1
  state = 0;
 67a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 67c:	02500a13          	li	s4,37
 680:	4b55                	li	s6,21
 682:	a839                	j	6a0 <vprintf+0x4c>
        putc(fd, c);
 684:	85ca                	mv	a1,s2
 686:	8556                	mv	a0,s5
 688:	00000097          	auipc	ra,0x0
 68c:	efe080e7          	jalr	-258(ra) # 586 <putc>
 690:	a019                	j	696 <vprintf+0x42>
    } else if(state == '%'){
 692:	01498d63          	beq	s3,s4,6ac <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 696:	0485                	add	s1,s1,1
 698:	fff4c903          	lbu	s2,-1(s1)
 69c:	16090763          	beqz	s2,80a <vprintf+0x1b6>
    if(state == 0){
 6a0:	fe0999e3          	bnez	s3,692 <vprintf+0x3e>
      if(c == '%'){
 6a4:	ff4910e3          	bne	s2,s4,684 <vprintf+0x30>
        state = '%';
 6a8:	89d2                	mv	s3,s4
 6aa:	b7f5                	j	696 <vprintf+0x42>
      if(c == 'd'){
 6ac:	13490463          	beq	s2,s4,7d4 <vprintf+0x180>
 6b0:	f9d9079b          	addw	a5,s2,-99
 6b4:	0ff7f793          	zext.b	a5,a5
 6b8:	12fb6763          	bltu	s6,a5,7e6 <vprintf+0x192>
 6bc:	f9d9079b          	addw	a5,s2,-99
 6c0:	0ff7f713          	zext.b	a4,a5
 6c4:	12eb6163          	bltu	s6,a4,7e6 <vprintf+0x192>
 6c8:	00271793          	sll	a5,a4,0x2
 6cc:	00000717          	auipc	a4,0x0
 6d0:	4d470713          	add	a4,a4,1236 # ba0 <malloc+0x29a>
 6d4:	97ba                	add	a5,a5,a4
 6d6:	439c                	lw	a5,0(a5)
 6d8:	97ba                	add	a5,a5,a4
 6da:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 6dc:	008b8913          	add	s2,s7,8
 6e0:	4685                	li	a3,1
 6e2:	4629                	li	a2,10
 6e4:	000ba583          	lw	a1,0(s7)
 6e8:	8556                	mv	a0,s5
 6ea:	00000097          	auipc	ra,0x0
 6ee:	ebe080e7          	jalr	-322(ra) # 5a8 <printint>
 6f2:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6f4:	4981                	li	s3,0
 6f6:	b745                	j	696 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f8:	008b8913          	add	s2,s7,8
 6fc:	4681                	li	a3,0
 6fe:	4629                	li	a2,10
 700:	000ba583          	lw	a1,0(s7)
 704:	8556                	mv	a0,s5
 706:	00000097          	auipc	ra,0x0
 70a:	ea2080e7          	jalr	-350(ra) # 5a8 <printint>
 70e:	8bca                	mv	s7,s2
      state = 0;
 710:	4981                	li	s3,0
 712:	b751                	j	696 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 714:	008b8913          	add	s2,s7,8
 718:	4681                	li	a3,0
 71a:	4641                	li	a2,16
 71c:	000ba583          	lw	a1,0(s7)
 720:	8556                	mv	a0,s5
 722:	00000097          	auipc	ra,0x0
 726:	e86080e7          	jalr	-378(ra) # 5a8 <printint>
 72a:	8bca                	mv	s7,s2
      state = 0;
 72c:	4981                	li	s3,0
 72e:	b7a5                	j	696 <vprintf+0x42>
 730:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 732:	008b8c13          	add	s8,s7,8
 736:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 73a:	03000593          	li	a1,48
 73e:	8556                	mv	a0,s5
 740:	00000097          	auipc	ra,0x0
 744:	e46080e7          	jalr	-442(ra) # 586 <putc>
  putc(fd, 'x');
 748:	07800593          	li	a1,120
 74c:	8556                	mv	a0,s5
 74e:	00000097          	auipc	ra,0x0
 752:	e38080e7          	jalr	-456(ra) # 586 <putc>
 756:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 758:	00000b97          	auipc	s7,0x0
 75c:	4a0b8b93          	add	s7,s7,1184 # bf8 <digits>
 760:	03c9d793          	srl	a5,s3,0x3c
 764:	97de                	add	a5,a5,s7
 766:	0007c583          	lbu	a1,0(a5)
 76a:	8556                	mv	a0,s5
 76c:	00000097          	auipc	ra,0x0
 770:	e1a080e7          	jalr	-486(ra) # 586 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 774:	0992                	sll	s3,s3,0x4
 776:	397d                	addw	s2,s2,-1
 778:	fe0914e3          	bnez	s2,760 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 77c:	8be2                	mv	s7,s8
      state = 0;
 77e:	4981                	li	s3,0
 780:	6c02                	ld	s8,0(sp)
 782:	bf11                	j	696 <vprintf+0x42>
        s = va_arg(ap, char*);
 784:	008b8993          	add	s3,s7,8
 788:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 78c:	02090163          	beqz	s2,7ae <vprintf+0x15a>
        while(*s != 0){
 790:	00094583          	lbu	a1,0(s2)
 794:	c9a5                	beqz	a1,804 <vprintf+0x1b0>
          putc(fd, *s);
 796:	8556                	mv	a0,s5
 798:	00000097          	auipc	ra,0x0
 79c:	dee080e7          	jalr	-530(ra) # 586 <putc>
          s++;
 7a0:	0905                	add	s2,s2,1
        while(*s != 0){
 7a2:	00094583          	lbu	a1,0(s2)
 7a6:	f9e5                	bnez	a1,796 <vprintf+0x142>
        s = va_arg(ap, char*);
 7a8:	8bce                	mv	s7,s3
      state = 0;
 7aa:	4981                	li	s3,0
 7ac:	b5ed                	j	696 <vprintf+0x42>
          s = "(null)";
 7ae:	00000917          	auipc	s2,0x0
 7b2:	3ea90913          	add	s2,s2,1002 # b98 <malloc+0x292>
        while(*s != 0){
 7b6:	02800593          	li	a1,40
 7ba:	bff1                	j	796 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 7bc:	008b8913          	add	s2,s7,8
 7c0:	000bc583          	lbu	a1,0(s7)
 7c4:	8556                	mv	a0,s5
 7c6:	00000097          	auipc	ra,0x0
 7ca:	dc0080e7          	jalr	-576(ra) # 586 <putc>
 7ce:	8bca                	mv	s7,s2
      state = 0;
 7d0:	4981                	li	s3,0
 7d2:	b5d1                	j	696 <vprintf+0x42>
        putc(fd, c);
 7d4:	02500593          	li	a1,37
 7d8:	8556                	mv	a0,s5
 7da:	00000097          	auipc	ra,0x0
 7de:	dac080e7          	jalr	-596(ra) # 586 <putc>
      state = 0;
 7e2:	4981                	li	s3,0
 7e4:	bd4d                	j	696 <vprintf+0x42>
        putc(fd, '%');
 7e6:	02500593          	li	a1,37
 7ea:	8556                	mv	a0,s5
 7ec:	00000097          	auipc	ra,0x0
 7f0:	d9a080e7          	jalr	-614(ra) # 586 <putc>
        putc(fd, c);
 7f4:	85ca                	mv	a1,s2
 7f6:	8556                	mv	a0,s5
 7f8:	00000097          	auipc	ra,0x0
 7fc:	d8e080e7          	jalr	-626(ra) # 586 <putc>
      state = 0;
 800:	4981                	li	s3,0
 802:	bd51                	j	696 <vprintf+0x42>
        s = va_arg(ap, char*);
 804:	8bce                	mv	s7,s3
      state = 0;
 806:	4981                	li	s3,0
 808:	b579                	j	696 <vprintf+0x42>
 80a:	74e2                	ld	s1,56(sp)
 80c:	79a2                	ld	s3,40(sp)
 80e:	7a02                	ld	s4,32(sp)
 810:	6ae2                	ld	s5,24(sp)
 812:	6b42                	ld	s6,16(sp)
 814:	6ba2                	ld	s7,8(sp)
    }
  }
}
 816:	60a6                	ld	ra,72(sp)
 818:	6406                	ld	s0,64(sp)
 81a:	7942                	ld	s2,48(sp)
 81c:	6161                	add	sp,sp,80
 81e:	8082                	ret

0000000000000820 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 820:	715d                	add	sp,sp,-80
 822:	ec06                	sd	ra,24(sp)
 824:	e822                	sd	s0,16(sp)
 826:	1000                	add	s0,sp,32
 828:	e010                	sd	a2,0(s0)
 82a:	e414                	sd	a3,8(s0)
 82c:	e818                	sd	a4,16(s0)
 82e:	ec1c                	sd	a5,24(s0)
 830:	03043023          	sd	a6,32(s0)
 834:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 838:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 83c:	8622                	mv	a2,s0
 83e:	00000097          	auipc	ra,0x0
 842:	e16080e7          	jalr	-490(ra) # 654 <vprintf>
}
 846:	60e2                	ld	ra,24(sp)
 848:	6442                	ld	s0,16(sp)
 84a:	6161                	add	sp,sp,80
 84c:	8082                	ret

000000000000084e <printf>:

void
printf(const char *fmt, ...)
{
 84e:	711d                	add	sp,sp,-96
 850:	ec06                	sd	ra,24(sp)
 852:	e822                	sd	s0,16(sp)
 854:	1000                	add	s0,sp,32
 856:	e40c                	sd	a1,8(s0)
 858:	e810                	sd	a2,16(s0)
 85a:	ec14                	sd	a3,24(s0)
 85c:	f018                	sd	a4,32(s0)
 85e:	f41c                	sd	a5,40(s0)
 860:	03043823          	sd	a6,48(s0)
 864:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 868:	00840613          	add	a2,s0,8
 86c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 870:	85aa                	mv	a1,a0
 872:	4505                	li	a0,1
 874:	00000097          	auipc	ra,0x0
 878:	de0080e7          	jalr	-544(ra) # 654 <vprintf>
}
 87c:	60e2                	ld	ra,24(sp)
 87e:	6442                	ld	s0,16(sp)
 880:	6125                	add	sp,sp,96
 882:	8082                	ret

0000000000000884 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 884:	1141                	add	sp,sp,-16
 886:	e422                	sd	s0,8(sp)
 888:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 88a:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 88e:	00001797          	auipc	a5,0x1
 892:	bd27b783          	ld	a5,-1070(a5) # 1460 <freep>
 896:	a02d                	j	8c0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 898:	4618                	lw	a4,8(a2)
 89a:	9f2d                	addw	a4,a4,a1
 89c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8a0:	6398                	ld	a4,0(a5)
 8a2:	6310                	ld	a2,0(a4)
 8a4:	a83d                	j	8e2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8a6:	ff852703          	lw	a4,-8(a0)
 8aa:	9f31                	addw	a4,a4,a2
 8ac:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8ae:	ff053683          	ld	a3,-16(a0)
 8b2:	a091                	j	8f6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8b4:	6398                	ld	a4,0(a5)
 8b6:	00e7e463          	bltu	a5,a4,8be <free+0x3a>
 8ba:	00e6ea63          	bltu	a3,a4,8ce <free+0x4a>
{
 8be:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8c0:	fed7fae3          	bgeu	a5,a3,8b4 <free+0x30>
 8c4:	6398                	ld	a4,0(a5)
 8c6:	00e6e463          	bltu	a3,a4,8ce <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ca:	fee7eae3          	bltu	a5,a4,8be <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8ce:	ff852583          	lw	a1,-8(a0)
 8d2:	6390                	ld	a2,0(a5)
 8d4:	02059813          	sll	a6,a1,0x20
 8d8:	01c85713          	srl	a4,a6,0x1c
 8dc:	9736                	add	a4,a4,a3
 8de:	fae60de3          	beq	a2,a4,898 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8e2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8e6:	4790                	lw	a2,8(a5)
 8e8:	02061593          	sll	a1,a2,0x20
 8ec:	01c5d713          	srl	a4,a1,0x1c
 8f0:	973e                	add	a4,a4,a5
 8f2:	fae68ae3          	beq	a3,a4,8a6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8f6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8f8:	00001717          	auipc	a4,0x1
 8fc:	b6f73423          	sd	a5,-1176(a4) # 1460 <freep>
}
 900:	6422                	ld	s0,8(sp)
 902:	0141                	add	sp,sp,16
 904:	8082                	ret

0000000000000906 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 906:	7139                	add	sp,sp,-64
 908:	fc06                	sd	ra,56(sp)
 90a:	f822                	sd	s0,48(sp)
 90c:	f426                	sd	s1,40(sp)
 90e:	ec4e                	sd	s3,24(sp)
 910:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 912:	02051493          	sll	s1,a0,0x20
 916:	9081                	srl	s1,s1,0x20
 918:	04bd                	add	s1,s1,15
 91a:	8091                	srl	s1,s1,0x4
 91c:	0014899b          	addw	s3,s1,1
 920:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 922:	00001517          	auipc	a0,0x1
 926:	b3e53503          	ld	a0,-1218(a0) # 1460 <freep>
 92a:	c915                	beqz	a0,95e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 92c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 92e:	4798                	lw	a4,8(a5)
 930:	08977e63          	bgeu	a4,s1,9cc <malloc+0xc6>
 934:	f04a                	sd	s2,32(sp)
 936:	e852                	sd	s4,16(sp)
 938:	e456                	sd	s5,8(sp)
 93a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 93c:	8a4e                	mv	s4,s3
 93e:	0009871b          	sext.w	a4,s3
 942:	6685                	lui	a3,0x1
 944:	00d77363          	bgeu	a4,a3,94a <malloc+0x44>
 948:	6a05                	lui	s4,0x1
 94a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 94e:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 952:	00001917          	auipc	s2,0x1
 956:	b0e90913          	add	s2,s2,-1266 # 1460 <freep>
  if(p == (char*)-1)
 95a:	5afd                	li	s5,-1
 95c:	a091                	j	9a0 <malloc+0x9a>
 95e:	f04a                	sd	s2,32(sp)
 960:	e852                	sd	s4,16(sp)
 962:	e456                	sd	s5,8(sp)
 964:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 966:	00001797          	auipc	a5,0x1
 96a:	b0a78793          	add	a5,a5,-1270 # 1470 <base>
 96e:	00001717          	auipc	a4,0x1
 972:	aef73923          	sd	a5,-1294(a4) # 1460 <freep>
 976:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 978:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 97c:	b7c1                	j	93c <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 97e:	6398                	ld	a4,0(a5)
 980:	e118                	sd	a4,0(a0)
 982:	a08d                	j	9e4 <malloc+0xde>
  hp->s.size = nu;
 984:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 988:	0541                	add	a0,a0,16
 98a:	00000097          	auipc	ra,0x0
 98e:	efa080e7          	jalr	-262(ra) # 884 <free>
  return freep;
 992:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 996:	c13d                	beqz	a0,9fc <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 998:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 99a:	4798                	lw	a4,8(a5)
 99c:	02977463          	bgeu	a4,s1,9c4 <malloc+0xbe>
    if(p == freep)
 9a0:	00093703          	ld	a4,0(s2)
 9a4:	853e                	mv	a0,a5
 9a6:	fef719e3          	bne	a4,a5,998 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 9aa:	8552                	mv	a0,s4
 9ac:	00000097          	auipc	ra,0x0
 9b0:	baa080e7          	jalr	-1110(ra) # 556 <sbrk>
  if(p == (char*)-1)
 9b4:	fd5518e3          	bne	a0,s5,984 <malloc+0x7e>
        return 0;
 9b8:	4501                	li	a0,0
 9ba:	7902                	ld	s2,32(sp)
 9bc:	6a42                	ld	s4,16(sp)
 9be:	6aa2                	ld	s5,8(sp)
 9c0:	6b02                	ld	s6,0(sp)
 9c2:	a03d                	j	9f0 <malloc+0xea>
 9c4:	7902                	ld	s2,32(sp)
 9c6:	6a42                	ld	s4,16(sp)
 9c8:	6aa2                	ld	s5,8(sp)
 9ca:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9cc:	fae489e3          	beq	s1,a4,97e <malloc+0x78>
        p->s.size -= nunits;
 9d0:	4137073b          	subw	a4,a4,s3
 9d4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9d6:	02071693          	sll	a3,a4,0x20
 9da:	01c6d713          	srl	a4,a3,0x1c
 9de:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9e0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9e4:	00001717          	auipc	a4,0x1
 9e8:	a6a73e23          	sd	a0,-1412(a4) # 1460 <freep>
      return (void*)(p + 1);
 9ec:	01078513          	add	a0,a5,16
  }
}
 9f0:	70e2                	ld	ra,56(sp)
 9f2:	7442                	ld	s0,48(sp)
 9f4:	74a2                	ld	s1,40(sp)
 9f6:	69e2                	ld	s3,24(sp)
 9f8:	6121                	add	sp,sp,64
 9fa:	8082                	ret
 9fc:	7902                	ld	s2,32(sp)
 9fe:	6a42                	ld	s4,16(sp)
 a00:	6aa2                	ld	s5,8(sp)
 a02:	6b02                	ld	s6,0(sp)
 a04:	b7f5                	j	9f0 <malloc+0xea>
