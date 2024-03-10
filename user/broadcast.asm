
user/_broadcast:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <panic>:
};


void
panic(char *s)
{
   0:	1141                	add	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	add	s0,sp,16
   8:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
   a:	00001597          	auipc	a1,0x1
   e:	b5658593          	add	a1,a1,-1194 # b60 <malloc+0x10e>
  12:	4509                	li	a0,2
  14:	00001097          	auipc	ra,0x1
  18:	958080e7          	jalr	-1704(ra) # 96c <fprintf>
  exit(1);
  1c:	4505                	li	a0,1
  1e:	00000097          	auipc	ra,0x0
  22:	5fc080e7          	jalr	1532(ra) # 61a <exit>

0000000000000026 <fork1>:
}

//create a new process
int
fork1(void)
{
  26:	1141                	add	sp,sp,-16
  28:	e406                	sd	ra,8(sp)
  2a:	e022                	sd	s0,0(sp)
  2c:	0800                	add	s0,sp,16
  int pid;
  pid = fork();
  2e:	00000097          	auipc	ra,0x0
  32:	5e4080e7          	jalr	1508(ra) # 612 <fork>
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
  48:	b2450513          	add	a0,a0,-1244 # b68 <malloc+0x116>
  4c:	00000097          	auipc	ra,0x0
  50:	fb4080e7          	jalr	-76(ra) # 0 <panic>

0000000000000054 <pipe1>:

//create a pipe
void
pipe1(int fd[2])
{
  54:	1141                	add	sp,sp,-16
  56:	e406                	sd	ra,8(sp)
  58:	e022                	sd	s0,0(sp)
  5a:	0800                	add	s0,sp,16
 int rc = pipe(fd);
  5c:	00000097          	auipc	ra,0x0
  60:	5ce080e7          	jalr	1486(ra) # 62a <pipe>
 if(rc<0){
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
  74:	b0050513          	add	a0,a0,-1280 # b70 <malloc+0x11e>
  78:	00000097          	auipc	ra,0x0
  7c:	f88080e7          	jalr	-120(ra) # 0 <panic>

0000000000000080 <main>:
int ps(char *psinfo);

int getschedhistory(char *history);

int main(int argc, char *argv[])
{
  80:	81010113          	add	sp,sp,-2032
  84:	7e113423          	sd	ra,2024(sp)
  88:	7e813023          	sd	s0,2016(sp)
  8c:	7c913c23          	sd	s1,2008(sp)
  90:	7d213823          	sd	s2,2000(sp)
  94:	7d313423          	sd	s3,1992(sp)
  98:	7d413023          	sd	s4,1984(sp)
  9c:	7b513c23          	sd	s5,1976(sp)
  a0:	7f010413          	add	s0,sp,2032
  a4:	b0010113          	add	sp,sp,-1280
    if(argc<3){
  a8:	4789                	li	a5,2
  aa:	00a7ca63          	blt	a5,a0,be <main+0x3e>
        panic("Usage: broadcast <num_of_receivers> <msg_to_broadcast>");
  ae:	00001517          	auipc	a0,0x1
  b2:	ada50513          	add	a0,a0,-1318 # b88 <malloc+0x136>
  b6:	00000097          	auipc	ra,0x0
  ba:	f4a080e7          	jalr	-182(ra) # 0 <panic>
  be:	8a2e                	mv	s4,a1
    }

    int numReceiver = atoi(argv[1]);
  c0:	6588                	ld	a0,8(a1)
  c2:	00000097          	auipc	ra,0x0
  c6:	45e080e7          	jalr	1118(ra) # 520 <atoi>
  ca:	84aa                	mv	s1,a0
    
    //create a pair of pipes as communication channels
    int channelToReceivers[2], channelFromReceivers[2];
    pipe(channelToReceivers);
  cc:	fb840513          	add	a0,s0,-72
  d0:	00000097          	auipc	ra,0x0
  d4:	55a080e7          	jalr	1370(ra) # 62a <pipe>
    pipe(channelFromReceivers);
  d8:	fb040513          	add	a0,s0,-80
  dc:	00000097          	auipc	ra,0x0
  e0:	54e080e7          	jalr	1358(ra) # 62a <pipe>
    
    for(int i=0; i<numReceiver; i++){
  e4:	02905c63          	blez	s1,11c <main+0x9c>
  e8:	4901                	li	s2,0
	    //end of the child process
            exit(0);
		

        }else{
            printf("Parent: creates child process with id: %d\n", i);
  ea:	00001a97          	auipc	s5,0x1
  ee:	b16a8a93          	add	s5,s5,-1258 # c00 <malloc+0x1ae>
        int retFork = fork1();
  f2:	00000097          	auipc	ra,0x0
  f6:	f34080e7          	jalr	-204(ra) # 26 <fork1>
  fa:	89aa                	mv	s3,a0
        if(retFork==0){
  fc:	1a050f63          	beqz	a0,2ba <main+0x23a>
            printf("Parent: creates child process with id: %d\n", i);
 100:	85ca                	mv	a1,s2
 102:	8556                	mv	a0,s5
 104:	00001097          	auipc	ra,0x1
 108:	896080e7          	jalr	-1898(ra) # 99a <printf>
        }
        sleep(1);
 10c:	4505                	li	a0,1
 10e:	00000097          	auipc	ra,0x0
 112:	59c080e7          	jalr	1436(ra) # 6aa <sleep>
    for(int i=0; i<numReceiver; i++){
 116:	2905                	addw	s2,s2,1
 118:	fd249de3          	bne	s1,s2,f2 <main+0x72>
            printf("Child %d: start!\n", myId);
 11c:	00bc6737          	lui	a4,0xbc6
 120:	14e70713          	add	a4,a4,334 # bc614e <base+0xbc4cde>
 124:	06400693          	li	a3,100
 128:	87b6                	mv	a5,a3
    /*following is the parent's code*/
    
    //to fake some computation workload for Project 1.B
    float x=123456.0;
    for(int i=0; i<12345678; i++)
	    for(int j=0; j<100; j++) 
 12a:	37fd                	addw	a5,a5,-1
 12c:	fffd                	bnez	a5,12a <main+0xaa>
    for(int i=0; i<12345678; i++)
 12e:	377d                	addw	a4,a4,-1
 130:	ff65                	bnez	a4,128 <main+0xa8>
		    x=x*x;

    //to broadcast message
    struct msg_t msg;
    for(int i=0; i<numReceiver; i++)
 132:	00905c63          	blez	s1,14a <main+0xca>
 136:	e8840713          	add	a4,s0,-376
 13a:	00249793          	sll	a5,s1,0x2
 13e:	97ba                	add	a5,a5,a4
        msg.flags[i] = 1;
 140:	4685                	li	a3,1
 142:	c314                	sw	a3,0(a4)
    for(int i=0; i<numReceiver; i++)
 144:	0711                	add	a4,a4,4
 146:	fef71ee3          	bne	a4,a5,142 <main+0xc2>
    strcpy(msg.content, argv[2]);
 14a:	010a3583          	ld	a1,16(s4)
 14e:	eb040513          	add	a0,s0,-336
 152:	00000097          	auipc	ra,0x0
 156:	25c080e7          	jalr	604(ra) # 3ae <strcpy>
    write(channelToReceivers[1], &msg, sizeof(struct msg_t));
 15a:	12800613          	li	a2,296
 15e:	e8840593          	add	a1,s0,-376
 162:	fbc42503          	lw	a0,-68(s0)
 166:	00000097          	auipc	ra,0x0
 16a:	4d4080e7          	jalr	1236(ra) # 63a <write>
    printf("Parent broadcasts: %s\n", msg.content);
 16e:	eb040593          	add	a1,s0,-336
 172:	00001517          	auipc	a0,0x1
 176:	abe50513          	add	a0,a0,-1346 # c30 <malloc+0x1de>
 17a:	00001097          	auipc	ra,0x1
 17e:	820080e7          	jalr	-2016(ra) # 99a <printf>

    //to receive acknowledgement
    char recvBuf[sizeof(struct msg_t)];        
    read(channelFromReceivers[0], &recvBuf, sizeof(struct msg_t));
 182:	12800613          	li	a2,296
 186:	d6040593          	add	a1,s0,-672
 18a:	fb042503          	lw	a0,-80(s0)
 18e:	00000097          	auipc	ra,0x0
 192:	4a4080e7          	jalr	1188(ra) # 632 <read>
    printf("Parent receives: %s\n", recvBuf);
 196:	d6040593          	add	a1,s0,-672
 19a:	00001517          	auipc	a0,0x1
 19e:	aae50513          	add	a0,a0,-1362 # c48 <malloc+0x1f6>
 1a2:	00000097          	auipc	ra,0x0
 1a6:	7f8080e7          	jalr	2040(ra) # 99a <printf>

    //call the new system calls for Project 1.B
    printf("\nCall system calls for Project 1.B\n\n");
 1aa:	00001517          	auipc	a0,0x1
 1ae:	ab650513          	add	a0,a0,-1354 # c60 <malloc+0x20e>
 1b2:	00000097          	auipc	ra,0x0
 1b6:	7e8080e7          	jalr	2024(ra) # 99a <printf>

    printf("Result from calling getppid:\n");
 1ba:	00001517          	auipc	a0,0x1
 1be:	ace50513          	add	a0,a0,-1330 # c88 <malloc+0x236>
 1c2:	00000097          	auipc	ra,0x0
 1c6:	7d8080e7          	jalr	2008(ra) # 99a <printf>
    int ppid = getppid();
 1ca:	00000097          	auipc	ra,0x0
 1ce:	4f0080e7          	jalr	1264(ra) # 6ba <getppid>
 1d2:	85aa                	mv	a1,a0
    printf("My ppid = %d\n", ppid);
 1d4:	00001517          	auipc	a0,0x1
 1d8:	ad450513          	add	a0,a0,-1324 # ca8 <malloc+0x256>
 1dc:	00000097          	auipc	ra,0x0
 1e0:	7be080e7          	jalr	1982(ra) # 99a <printf>

    printf("\nResult from calling ps:\n");
 1e4:	00001517          	auipc	a0,0x1
 1e8:	ad450513          	add	a0,a0,-1324 # cb8 <malloc+0x266>
 1ec:	00000097          	auipc	ra,0x0
 1f0:	7ae080e7          	jalr	1966(ra) # 99a <printf>
    int ret;
    struct ps_struct myPS[64];
    ret = ps((char *)&myPS);
 1f4:	757d                	lui	a0,0xfffff
 1f6:	46050793          	add	a5,a0,1120 # fffffffffffff460 <base+0xffffffffffffdff0>
 1fa:	00878533          	add	a0,a5,s0
 1fe:	00000097          	auipc	ra,0x0
 202:	4c4080e7          	jalr	1220(ra) # 6c2 <ps>
 206:	892a                	mv	s2,a0
    printf("Total number of processes: %d\n", ret);
 208:	85aa                	mv	a1,a0
 20a:	00001517          	auipc	a0,0x1
 20e:	ace50513          	add	a0,a0,-1330 # cd8 <malloc+0x286>
 212:	00000097          	auipc	ra,0x0
 216:	788080e7          	jalr	1928(ra) # 99a <printf>
    for(int i=0; i<ret; i++){
 21a:	05205063          	blez	s2,25a <main+0x1da>
 21e:	74fd                	lui	s1,0xfffff
 220:	46848793          	add	a5,s1,1128 # fffffffffffff468 <base+0xffffffffffffdff8>
 224:	008784b3          	add	s1,a5,s0
 228:	02400793          	li	a5,36
 22c:	02f90933          	mul	s2,s2,a5
 230:	9926                	add	s2,s2,s1
        printf("pid: %d, ppid: %d, state: %s, name: %s\n",
 232:	00001997          	auipc	s3,0x1
 236:	ac698993          	add	s3,s3,-1338 # cf8 <malloc+0x2a6>
 23a:	00a48713          	add	a4,s1,10
 23e:	86a6                	mv	a3,s1
 240:	ffc4a603          	lw	a2,-4(s1)
 244:	ff84a583          	lw	a1,-8(s1)
 248:	854e                	mv	a0,s3
 24a:	00000097          	auipc	ra,0x0
 24e:	750080e7          	jalr	1872(ra) # 99a <printf>
    for(int i=0; i<ret; i++){
 252:	02448493          	add	s1,s1,36
 256:	ff2492e3          	bne	s1,s2,23a <main+0x1ba>
        myPS[i].pid, myPS[i].ppid, myPS[i].state, myPS[i].name);
    }

    printf("\nResult from calling getschedhistory:\n");
 25a:	00001517          	auipc	a0,0x1
 25e:	ac650513          	add	a0,a0,-1338 # d20 <malloc+0x2ce>
 262:	00000097          	auipc	ra,0x0
 266:	738080e7          	jalr	1848(ra) # 99a <printf>
    struct sched_history myHistory;
    ret = getschedhistory((char *)&myHistory);
 26a:	757d                	lui	a0,0xfffff
 26c:	44850793          	add	a5,a0,1096 # fffffffffffff448 <base+0xffffffffffffdfd8>
 270:	00878533          	add	a0,a5,s0
 274:	00000097          	auipc	ra,0x0
 278:	456080e7          	jalr	1110(ra) # 6ca <getschedhistory>
 27c:	85aa                	mv	a1,a0
    printf("My scheduling history\n pid: %d\n runs: %d, traps: %d, interrupts: %d, preemptions: %d, sleeps: %d, system calls: %d\n",
 27e:	767d                	lui	a2,0xfffff
 280:	fc060793          	add	a5,a2,-64 # ffffffffffffefc0 <base+0xffffffffffffdb50>
 284:	00878633          	add	a2,a5,s0
 288:	48c62883          	lw	a7,1164(a2)
 28c:	49c62803          	lw	a6,1180(a2)
 290:	49462783          	lw	a5,1172(a2)
 294:	49062703          	lw	a4,1168(a2)
 298:	49862683          	lw	a3,1176(a2)
 29c:	48862603          	lw	a2,1160(a2)
 2a0:	00001517          	auipc	a0,0x1
 2a4:	aa850513          	add	a0,a0,-1368 # d48 <malloc+0x2f6>
 2a8:	00000097          	auipc	ra,0x0
 2ac:	6f2080e7          	jalr	1778(ra) # 99a <printf>
        ret, myHistory.runCount, myHistory.trapCount, myHistory.interruptCount,
        myHistory.preemptCount, myHistory.sleepCount, myHistory.systemcallCount);

    //end of parent process 
    exit(0);
 2b0:	4501                	li	a0,0
 2b2:	00000097          	auipc	ra,0x0
 2b6:	368080e7          	jalr	872(ra) # 61a <exit>
            printf("Child %d: start!\n", myId);
 2ba:	85ca                	mv	a1,s2
 2bc:	00001517          	auipc	a0,0x1
 2c0:	90450513          	add	a0,a0,-1788 # bc0 <malloc+0x16e>
 2c4:	00000097          	auipc	ra,0x0
 2c8:	6d6080e7          	jalr	1750(ra) # 99a <printf>
 2cc:	00bc6737          	lui	a4,0xbc6
 2d0:	14e70713          	add	a4,a4,334 # bc614e <base+0xbc4cde>
    for(int i=0; i<numReceiver; i++){
 2d4:	06400693          	li	a3,100
 2d8:	87b6                	mv	a5,a3
		    for(int j=0; j<100; j++)
 2da:	37fd                	addw	a5,a5,-1
 2dc:	fffd                	bnez	a5,2da <main+0x25a>
	    for(int i=0; i<12345678; i++)
 2de:	377d                	addw	a4,a4,-1
 2e0:	ff65                	bnez	a4,2d8 <main+0x258>
            read(channelToReceivers[0], 
 2e2:	77fd                	lui	a5,0xfffff
 2e4:	32078793          	add	a5,a5,800 # fffffffffffff320 <base+0xffffffffffffdeb0>
 2e8:	97a2                	add	a5,a5,s0
 2ea:	7a7d                	lui	s4,0xfffff
 2ec:	318a0713          	add	a4,s4,792 # fffffffffffff318 <base+0xffffffffffffdea8>
 2f0:	9722                	add	a4,a4,s0
 2f2:	e31c                	sd	a5,0(a4)
 2f4:	12800613          	li	a2,296
 2f8:	630c                	ld	a1,0(a4)
 2fa:	fb842503          	lw	a0,-72(s0)
 2fe:	00000097          	auipc	ra,0x0
 302:	334080e7          	jalr	820(ra) # 632 <read>
            printf("Child %d: get msg (%s)\n", 
 306:	318a0793          	add	a5,s4,792
 30a:	97a2                	add	a5,a5,s0
 30c:	639c                	ld	a5,0(a5)
 30e:	02878493          	add	s1,a5,40
 312:	8626                	mv	a2,s1
 314:	85ca                	mv	a1,s2
 316:	00001517          	auipc	a0,0x1
 31a:	8c250513          	add	a0,a0,-1854 # bd8 <malloc+0x186>
 31e:	00000097          	auipc	ra,0x0
 322:	67c080e7          	jalr	1660(ra) # 99a <printf>
            msg.flags[i]=0;
 326:	77fd                	lui	a5,0xfffff
 328:	090a                	sll	s2,s2,0x2
 32a:	fc078793          	add	a5,a5,-64 # ffffffffffffefc0 <base+0xffffffffffffdb50>
 32e:	97a2                	add	a5,a5,s0
 330:	310a0713          	add	a4,s4,784
 334:	9722                	add	a4,a4,s0
 336:	e31c                	sd	a5,0(a4)
 338:	631c                	ld	a5,0(a4)
 33a:	97ca                	add	a5,a5,s2
 33c:	3607a023          	sw	zero,864(a5)
            for(int j=0; j<MAX_NUM_RECEIVERS; j++)
 340:	318a0793          	add	a5,s4,792
 344:	97a2                	add	a5,a5,s0
 346:	639c                	ld	a5,0(a5)
                    sum += msg.flags[j];
 348:	4398                	lw	a4,0(a5)
 34a:	013709bb          	addw	s3,a4,s3
            for(int j=0; j<MAX_NUM_RECEIVERS; j++)
 34e:	0791                	add	a5,a5,4
 350:	fe979ce3          	bne	a5,s1,348 <main+0x2c8>
            if(sum==0){
 354:	02099263          	bnez	s3,378 <main+0x2f8>
                write(channelFromReceivers[1],"completed!",10);    
 358:	4629                	li	a2,10
 35a:	00001597          	auipc	a1,0x1
 35e:	89658593          	add	a1,a1,-1898 # bf0 <malloc+0x19e>
 362:	fb442503          	lw	a0,-76(s0)
 366:	00000097          	auipc	ra,0x0
 36a:	2d4080e7          	jalr	724(ra) # 63a <write>
            exit(0);
 36e:	4501                	li	a0,0
 370:	00000097          	auipc	ra,0x0
 374:	2aa080e7          	jalr	682(ra) # 61a <exit>
                write(channelToReceivers[1],&msg,sizeof(msg));
 378:	75fd                	lui	a1,0xfffff
 37a:	12800613          	li	a2,296
 37e:	32058793          	add	a5,a1,800 # fffffffffffff320 <base+0xffffffffffffdeb0>
 382:	008785b3          	add	a1,a5,s0
 386:	fbc42503          	lw	a0,-68(s0)
 38a:	00000097          	auipc	ra,0x0
 38e:	2b0080e7          	jalr	688(ra) # 63a <write>
 392:	bff1                	j	36e <main+0x2ee>

0000000000000394 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 394:	1141                	add	sp,sp,-16
 396:	e406                	sd	ra,8(sp)
 398:	e022                	sd	s0,0(sp)
 39a:	0800                	add	s0,sp,16
  extern int main();
  main();
 39c:	00000097          	auipc	ra,0x0
 3a0:	ce4080e7          	jalr	-796(ra) # 80 <main>
  exit(0);
 3a4:	4501                	li	a0,0
 3a6:	00000097          	auipc	ra,0x0
 3aa:	274080e7          	jalr	628(ra) # 61a <exit>

00000000000003ae <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 3ae:	1141                	add	sp,sp,-16
 3b0:	e422                	sd	s0,8(sp)
 3b2:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 3b4:	87aa                	mv	a5,a0
 3b6:	0585                	add	a1,a1,1
 3b8:	0785                	add	a5,a5,1
 3ba:	fff5c703          	lbu	a4,-1(a1)
 3be:	fee78fa3          	sb	a4,-1(a5)
 3c2:	fb75                	bnez	a4,3b6 <strcpy+0x8>
    ;
  return os;
}
 3c4:	6422                	ld	s0,8(sp)
 3c6:	0141                	add	sp,sp,16
 3c8:	8082                	ret

00000000000003ca <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3ca:	1141                	add	sp,sp,-16
 3cc:	e422                	sd	s0,8(sp)
 3ce:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 3d0:	00054783          	lbu	a5,0(a0)
 3d4:	cb91                	beqz	a5,3e8 <strcmp+0x1e>
 3d6:	0005c703          	lbu	a4,0(a1)
 3da:	00f71763          	bne	a4,a5,3e8 <strcmp+0x1e>
    p++, q++;
 3de:	0505                	add	a0,a0,1
 3e0:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 3e2:	00054783          	lbu	a5,0(a0)
 3e6:	fbe5                	bnez	a5,3d6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 3e8:	0005c503          	lbu	a0,0(a1)
}
 3ec:	40a7853b          	subw	a0,a5,a0
 3f0:	6422                	ld	s0,8(sp)
 3f2:	0141                	add	sp,sp,16
 3f4:	8082                	ret

00000000000003f6 <strlen>:

uint
strlen(const char *s)
{
 3f6:	1141                	add	sp,sp,-16
 3f8:	e422                	sd	s0,8(sp)
 3fa:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 3fc:	00054783          	lbu	a5,0(a0)
 400:	cf91                	beqz	a5,41c <strlen+0x26>
 402:	0505                	add	a0,a0,1
 404:	87aa                	mv	a5,a0
 406:	86be                	mv	a3,a5
 408:	0785                	add	a5,a5,1
 40a:	fff7c703          	lbu	a4,-1(a5)
 40e:	ff65                	bnez	a4,406 <strlen+0x10>
 410:	40a6853b          	subw	a0,a3,a0
 414:	2505                	addw	a0,a0,1
    ;
  return n;
}
 416:	6422                	ld	s0,8(sp)
 418:	0141                	add	sp,sp,16
 41a:	8082                	ret
  for(n = 0; s[n]; n++)
 41c:	4501                	li	a0,0
 41e:	bfe5                	j	416 <strlen+0x20>

0000000000000420 <memset>:

void*
memset(void *dst, int c, uint n)
{
 420:	1141                	add	sp,sp,-16
 422:	e422                	sd	s0,8(sp)
 424:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 426:	ca19                	beqz	a2,43c <memset+0x1c>
 428:	87aa                	mv	a5,a0
 42a:	1602                	sll	a2,a2,0x20
 42c:	9201                	srl	a2,a2,0x20
 42e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 432:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 436:	0785                	add	a5,a5,1
 438:	fee79de3          	bne	a5,a4,432 <memset+0x12>
  }
  return dst;
}
 43c:	6422                	ld	s0,8(sp)
 43e:	0141                	add	sp,sp,16
 440:	8082                	ret

0000000000000442 <strchr>:

char*
strchr(const char *s, char c)
{
 442:	1141                	add	sp,sp,-16
 444:	e422                	sd	s0,8(sp)
 446:	0800                	add	s0,sp,16
  for(; *s; s++)
 448:	00054783          	lbu	a5,0(a0)
 44c:	cb99                	beqz	a5,462 <strchr+0x20>
    if(*s == c)
 44e:	00f58763          	beq	a1,a5,45c <strchr+0x1a>
  for(; *s; s++)
 452:	0505                	add	a0,a0,1
 454:	00054783          	lbu	a5,0(a0)
 458:	fbfd                	bnez	a5,44e <strchr+0xc>
      return (char*)s;
  return 0;
 45a:	4501                	li	a0,0
}
 45c:	6422                	ld	s0,8(sp)
 45e:	0141                	add	sp,sp,16
 460:	8082                	ret
  return 0;
 462:	4501                	li	a0,0
 464:	bfe5                	j	45c <strchr+0x1a>

0000000000000466 <gets>:

char*
gets(char *buf, int max)
{
 466:	711d                	add	sp,sp,-96
 468:	ec86                	sd	ra,88(sp)
 46a:	e8a2                	sd	s0,80(sp)
 46c:	e4a6                	sd	s1,72(sp)
 46e:	e0ca                	sd	s2,64(sp)
 470:	fc4e                	sd	s3,56(sp)
 472:	f852                	sd	s4,48(sp)
 474:	f456                	sd	s5,40(sp)
 476:	f05a                	sd	s6,32(sp)
 478:	ec5e                	sd	s7,24(sp)
 47a:	1080                	add	s0,sp,96
 47c:	8baa                	mv	s7,a0
 47e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 480:	892a                	mv	s2,a0
 482:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 484:	4aa9                	li	s5,10
 486:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 488:	89a6                	mv	s3,s1
 48a:	2485                	addw	s1,s1,1
 48c:	0344d863          	bge	s1,s4,4bc <gets+0x56>
    cc = read(0, &c, 1);
 490:	4605                	li	a2,1
 492:	faf40593          	add	a1,s0,-81
 496:	4501                	li	a0,0
 498:	00000097          	auipc	ra,0x0
 49c:	19a080e7          	jalr	410(ra) # 632 <read>
    if(cc < 1)
 4a0:	00a05e63          	blez	a0,4bc <gets+0x56>
    buf[i++] = c;
 4a4:	faf44783          	lbu	a5,-81(s0)
 4a8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 4ac:	01578763          	beq	a5,s5,4ba <gets+0x54>
 4b0:	0905                	add	s2,s2,1
 4b2:	fd679be3          	bne	a5,s6,488 <gets+0x22>
    buf[i++] = c;
 4b6:	89a6                	mv	s3,s1
 4b8:	a011                	j	4bc <gets+0x56>
 4ba:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 4bc:	99de                	add	s3,s3,s7
 4be:	00098023          	sb	zero,0(s3)
  return buf;
}
 4c2:	855e                	mv	a0,s7
 4c4:	60e6                	ld	ra,88(sp)
 4c6:	6446                	ld	s0,80(sp)
 4c8:	64a6                	ld	s1,72(sp)
 4ca:	6906                	ld	s2,64(sp)
 4cc:	79e2                	ld	s3,56(sp)
 4ce:	7a42                	ld	s4,48(sp)
 4d0:	7aa2                	ld	s5,40(sp)
 4d2:	7b02                	ld	s6,32(sp)
 4d4:	6be2                	ld	s7,24(sp)
 4d6:	6125                	add	sp,sp,96
 4d8:	8082                	ret

00000000000004da <stat>:

int
stat(const char *n, struct stat *st)
{
 4da:	1101                	add	sp,sp,-32
 4dc:	ec06                	sd	ra,24(sp)
 4de:	e822                	sd	s0,16(sp)
 4e0:	e04a                	sd	s2,0(sp)
 4e2:	1000                	add	s0,sp,32
 4e4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4e6:	4581                	li	a1,0
 4e8:	00000097          	auipc	ra,0x0
 4ec:	172080e7          	jalr	370(ra) # 65a <open>
  if(fd < 0)
 4f0:	02054663          	bltz	a0,51c <stat+0x42>
 4f4:	e426                	sd	s1,8(sp)
 4f6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 4f8:	85ca                	mv	a1,s2
 4fa:	00000097          	auipc	ra,0x0
 4fe:	178080e7          	jalr	376(ra) # 672 <fstat>
 502:	892a                	mv	s2,a0
  close(fd);
 504:	8526                	mv	a0,s1
 506:	00000097          	auipc	ra,0x0
 50a:	13c080e7          	jalr	316(ra) # 642 <close>
  return r;
 50e:	64a2                	ld	s1,8(sp)
}
 510:	854a                	mv	a0,s2
 512:	60e2                	ld	ra,24(sp)
 514:	6442                	ld	s0,16(sp)
 516:	6902                	ld	s2,0(sp)
 518:	6105                	add	sp,sp,32
 51a:	8082                	ret
    return -1;
 51c:	597d                	li	s2,-1
 51e:	bfcd                	j	510 <stat+0x36>

0000000000000520 <atoi>:

int
atoi(const char *s)
{
 520:	1141                	add	sp,sp,-16
 522:	e422                	sd	s0,8(sp)
 524:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 526:	00054683          	lbu	a3,0(a0)
 52a:	fd06879b          	addw	a5,a3,-48
 52e:	0ff7f793          	zext.b	a5,a5
 532:	4625                	li	a2,9
 534:	02f66863          	bltu	a2,a5,564 <atoi+0x44>
 538:	872a                	mv	a4,a0
  n = 0;
 53a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 53c:	0705                	add	a4,a4,1
 53e:	0025179b          	sllw	a5,a0,0x2
 542:	9fa9                	addw	a5,a5,a0
 544:	0017979b          	sllw	a5,a5,0x1
 548:	9fb5                	addw	a5,a5,a3
 54a:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 54e:	00074683          	lbu	a3,0(a4)
 552:	fd06879b          	addw	a5,a3,-48
 556:	0ff7f793          	zext.b	a5,a5
 55a:	fef671e3          	bgeu	a2,a5,53c <atoi+0x1c>
  return n;
}
 55e:	6422                	ld	s0,8(sp)
 560:	0141                	add	sp,sp,16
 562:	8082                	ret
  n = 0;
 564:	4501                	li	a0,0
 566:	bfe5                	j	55e <atoi+0x3e>

0000000000000568 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 568:	1141                	add	sp,sp,-16
 56a:	e422                	sd	s0,8(sp)
 56c:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 56e:	02b57463          	bgeu	a0,a1,596 <memmove+0x2e>
    while(n-- > 0)
 572:	00c05f63          	blez	a2,590 <memmove+0x28>
 576:	1602                	sll	a2,a2,0x20
 578:	9201                	srl	a2,a2,0x20
 57a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 57e:	872a                	mv	a4,a0
      *dst++ = *src++;
 580:	0585                	add	a1,a1,1
 582:	0705                	add	a4,a4,1
 584:	fff5c683          	lbu	a3,-1(a1)
 588:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 58c:	fef71ae3          	bne	a4,a5,580 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 590:	6422                	ld	s0,8(sp)
 592:	0141                	add	sp,sp,16
 594:	8082                	ret
    dst += n;
 596:	00c50733          	add	a4,a0,a2
    src += n;
 59a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 59c:	fec05ae3          	blez	a2,590 <memmove+0x28>
 5a0:	fff6079b          	addw	a5,a2,-1
 5a4:	1782                	sll	a5,a5,0x20
 5a6:	9381                	srl	a5,a5,0x20
 5a8:	fff7c793          	not	a5,a5
 5ac:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 5ae:	15fd                	add	a1,a1,-1
 5b0:	177d                	add	a4,a4,-1
 5b2:	0005c683          	lbu	a3,0(a1)
 5b6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 5ba:	fee79ae3          	bne	a5,a4,5ae <memmove+0x46>
 5be:	bfc9                	j	590 <memmove+0x28>

00000000000005c0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 5c0:	1141                	add	sp,sp,-16
 5c2:	e422                	sd	s0,8(sp)
 5c4:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 5c6:	ca05                	beqz	a2,5f6 <memcmp+0x36>
 5c8:	fff6069b          	addw	a3,a2,-1
 5cc:	1682                	sll	a3,a3,0x20
 5ce:	9281                	srl	a3,a3,0x20
 5d0:	0685                	add	a3,a3,1
 5d2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 5d4:	00054783          	lbu	a5,0(a0)
 5d8:	0005c703          	lbu	a4,0(a1)
 5dc:	00e79863          	bne	a5,a4,5ec <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 5e0:	0505                	add	a0,a0,1
    p2++;
 5e2:	0585                	add	a1,a1,1
  while (n-- > 0) {
 5e4:	fed518e3          	bne	a0,a3,5d4 <memcmp+0x14>
  }
  return 0;
 5e8:	4501                	li	a0,0
 5ea:	a019                	j	5f0 <memcmp+0x30>
      return *p1 - *p2;
 5ec:	40e7853b          	subw	a0,a5,a4
}
 5f0:	6422                	ld	s0,8(sp)
 5f2:	0141                	add	sp,sp,16
 5f4:	8082                	ret
  return 0;
 5f6:	4501                	li	a0,0
 5f8:	bfe5                	j	5f0 <memcmp+0x30>

00000000000005fa <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 5fa:	1141                	add	sp,sp,-16
 5fc:	e406                	sd	ra,8(sp)
 5fe:	e022                	sd	s0,0(sp)
 600:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 602:	00000097          	auipc	ra,0x0
 606:	f66080e7          	jalr	-154(ra) # 568 <memmove>
}
 60a:	60a2                	ld	ra,8(sp)
 60c:	6402                	ld	s0,0(sp)
 60e:	0141                	add	sp,sp,16
 610:	8082                	ret

0000000000000612 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 612:	4885                	li	a7,1
 ecall
 614:	00000073          	ecall
 ret
 618:	8082                	ret

000000000000061a <exit>:
.global exit
exit:
 li a7, SYS_exit
 61a:	4889                	li	a7,2
 ecall
 61c:	00000073          	ecall
 ret
 620:	8082                	ret

0000000000000622 <wait>:
.global wait
wait:
 li a7, SYS_wait
 622:	488d                	li	a7,3
 ecall
 624:	00000073          	ecall
 ret
 628:	8082                	ret

000000000000062a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 62a:	4891                	li	a7,4
 ecall
 62c:	00000073          	ecall
 ret
 630:	8082                	ret

0000000000000632 <read>:
.global read
read:
 li a7, SYS_read
 632:	4895                	li	a7,5
 ecall
 634:	00000073          	ecall
 ret
 638:	8082                	ret

000000000000063a <write>:
.global write
write:
 li a7, SYS_write
 63a:	48c1                	li	a7,16
 ecall
 63c:	00000073          	ecall
 ret
 640:	8082                	ret

0000000000000642 <close>:
.global close
close:
 li a7, SYS_close
 642:	48d5                	li	a7,21
 ecall
 644:	00000073          	ecall
 ret
 648:	8082                	ret

000000000000064a <kill>:
.global kill
kill:
 li a7, SYS_kill
 64a:	4899                	li	a7,6
 ecall
 64c:	00000073          	ecall
 ret
 650:	8082                	ret

0000000000000652 <exec>:
.global exec
exec:
 li a7, SYS_exec
 652:	489d                	li	a7,7
 ecall
 654:	00000073          	ecall
 ret
 658:	8082                	ret

000000000000065a <open>:
.global open
open:
 li a7, SYS_open
 65a:	48bd                	li	a7,15
 ecall
 65c:	00000073          	ecall
 ret
 660:	8082                	ret

0000000000000662 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 662:	48c5                	li	a7,17
 ecall
 664:	00000073          	ecall
 ret
 668:	8082                	ret

000000000000066a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 66a:	48c9                	li	a7,18
 ecall
 66c:	00000073          	ecall
 ret
 670:	8082                	ret

0000000000000672 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 672:	48a1                	li	a7,8
 ecall
 674:	00000073          	ecall
 ret
 678:	8082                	ret

000000000000067a <link>:
.global link
link:
 li a7, SYS_link
 67a:	48cd                	li	a7,19
 ecall
 67c:	00000073          	ecall
 ret
 680:	8082                	ret

0000000000000682 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 682:	48d1                	li	a7,20
 ecall
 684:	00000073          	ecall
 ret
 688:	8082                	ret

000000000000068a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 68a:	48a5                	li	a7,9
 ecall
 68c:	00000073          	ecall
 ret
 690:	8082                	ret

0000000000000692 <dup>:
.global dup
dup:
 li a7, SYS_dup
 692:	48a9                	li	a7,10
 ecall
 694:	00000073          	ecall
 ret
 698:	8082                	ret

000000000000069a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 69a:	48ad                	li	a7,11
 ecall
 69c:	00000073          	ecall
 ret
 6a0:	8082                	ret

00000000000006a2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 6a2:	48b1                	li	a7,12
 ecall
 6a4:	00000073          	ecall
 ret
 6a8:	8082                	ret

00000000000006aa <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 6aa:	48b5                	li	a7,13
 ecall
 6ac:	00000073          	ecall
 ret
 6b0:	8082                	ret

00000000000006b2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 6b2:	48b9                	li	a7,14
 ecall
 6b4:	00000073          	ecall
 ret
 6b8:	8082                	ret

00000000000006ba <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 6ba:	48d9                	li	a7,22
 ecall
 6bc:	00000073          	ecall
 ret
 6c0:	8082                	ret

00000000000006c2 <ps>:
.global ps
ps:
 li a7, SYS_ps
 6c2:	48dd                	li	a7,23
 ecall
 6c4:	00000073          	ecall
 ret
 6c8:	8082                	ret

00000000000006ca <getschedhistory>:
.global getschedhistory
getschedhistory:
 li a7, SYS_getschedhistory
 6ca:	48e1                	li	a7,24
 ecall
 6cc:	00000073          	ecall
 ret
 6d0:	8082                	ret

00000000000006d2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 6d2:	1101                	add	sp,sp,-32
 6d4:	ec06                	sd	ra,24(sp)
 6d6:	e822                	sd	s0,16(sp)
 6d8:	1000                	add	s0,sp,32
 6da:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 6de:	4605                	li	a2,1
 6e0:	fef40593          	add	a1,s0,-17
 6e4:	00000097          	auipc	ra,0x0
 6e8:	f56080e7          	jalr	-170(ra) # 63a <write>
}
 6ec:	60e2                	ld	ra,24(sp)
 6ee:	6442                	ld	s0,16(sp)
 6f0:	6105                	add	sp,sp,32
 6f2:	8082                	ret

00000000000006f4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6f4:	7139                	add	sp,sp,-64
 6f6:	fc06                	sd	ra,56(sp)
 6f8:	f822                	sd	s0,48(sp)
 6fa:	f426                	sd	s1,40(sp)
 6fc:	0080                	add	s0,sp,64
 6fe:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 700:	c299                	beqz	a3,706 <printint+0x12>
 702:	0805cb63          	bltz	a1,798 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 706:	2581                	sext.w	a1,a1
  neg = 0;
 708:	4881                	li	a7,0
 70a:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 70e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 710:	2601                	sext.w	a2,a2
 712:	00000517          	auipc	a0,0x0
 716:	70e50513          	add	a0,a0,1806 # e20 <digits>
 71a:	883a                	mv	a6,a4
 71c:	2705                	addw	a4,a4,1
 71e:	02c5f7bb          	remuw	a5,a1,a2
 722:	1782                	sll	a5,a5,0x20
 724:	9381                	srl	a5,a5,0x20
 726:	97aa                	add	a5,a5,a0
 728:	0007c783          	lbu	a5,0(a5)
 72c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 730:	0005879b          	sext.w	a5,a1
 734:	02c5d5bb          	divuw	a1,a1,a2
 738:	0685                	add	a3,a3,1
 73a:	fec7f0e3          	bgeu	a5,a2,71a <printint+0x26>
  if(neg)
 73e:	00088c63          	beqz	a7,756 <printint+0x62>
    buf[i++] = '-';
 742:	fd070793          	add	a5,a4,-48
 746:	00878733          	add	a4,a5,s0
 74a:	02d00793          	li	a5,45
 74e:	fef70823          	sb	a5,-16(a4)
 752:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 756:	02e05c63          	blez	a4,78e <printint+0x9a>
 75a:	f04a                	sd	s2,32(sp)
 75c:	ec4e                	sd	s3,24(sp)
 75e:	fc040793          	add	a5,s0,-64
 762:	00e78933          	add	s2,a5,a4
 766:	fff78993          	add	s3,a5,-1
 76a:	99ba                	add	s3,s3,a4
 76c:	377d                	addw	a4,a4,-1
 76e:	1702                	sll	a4,a4,0x20
 770:	9301                	srl	a4,a4,0x20
 772:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 776:	fff94583          	lbu	a1,-1(s2)
 77a:	8526                	mv	a0,s1
 77c:	00000097          	auipc	ra,0x0
 780:	f56080e7          	jalr	-170(ra) # 6d2 <putc>
  while(--i >= 0)
 784:	197d                	add	s2,s2,-1
 786:	ff3918e3          	bne	s2,s3,776 <printint+0x82>
 78a:	7902                	ld	s2,32(sp)
 78c:	69e2                	ld	s3,24(sp)
}
 78e:	70e2                	ld	ra,56(sp)
 790:	7442                	ld	s0,48(sp)
 792:	74a2                	ld	s1,40(sp)
 794:	6121                	add	sp,sp,64
 796:	8082                	ret
    x = -xx;
 798:	40b005bb          	negw	a1,a1
    neg = 1;
 79c:	4885                	li	a7,1
    x = -xx;
 79e:	b7b5                	j	70a <printint+0x16>

00000000000007a0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 7a0:	715d                	add	sp,sp,-80
 7a2:	e486                	sd	ra,72(sp)
 7a4:	e0a2                	sd	s0,64(sp)
 7a6:	f84a                	sd	s2,48(sp)
 7a8:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 7aa:	0005c903          	lbu	s2,0(a1)
 7ae:	1a090a63          	beqz	s2,962 <vprintf+0x1c2>
 7b2:	fc26                	sd	s1,56(sp)
 7b4:	f44e                	sd	s3,40(sp)
 7b6:	f052                	sd	s4,32(sp)
 7b8:	ec56                	sd	s5,24(sp)
 7ba:	e85a                	sd	s6,16(sp)
 7bc:	e45e                	sd	s7,8(sp)
 7be:	8aaa                	mv	s5,a0
 7c0:	8bb2                	mv	s7,a2
 7c2:	00158493          	add	s1,a1,1
  state = 0;
 7c6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 7c8:	02500a13          	li	s4,37
 7cc:	4b55                	li	s6,21
 7ce:	a839                	j	7ec <vprintf+0x4c>
        putc(fd, c);
 7d0:	85ca                	mv	a1,s2
 7d2:	8556                	mv	a0,s5
 7d4:	00000097          	auipc	ra,0x0
 7d8:	efe080e7          	jalr	-258(ra) # 6d2 <putc>
 7dc:	a019                	j	7e2 <vprintf+0x42>
    } else if(state == '%'){
 7de:	01498d63          	beq	s3,s4,7f8 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 7e2:	0485                	add	s1,s1,1
 7e4:	fff4c903          	lbu	s2,-1(s1)
 7e8:	16090763          	beqz	s2,956 <vprintf+0x1b6>
    if(state == 0){
 7ec:	fe0999e3          	bnez	s3,7de <vprintf+0x3e>
      if(c == '%'){
 7f0:	ff4910e3          	bne	s2,s4,7d0 <vprintf+0x30>
        state = '%';
 7f4:	89d2                	mv	s3,s4
 7f6:	b7f5                	j	7e2 <vprintf+0x42>
      if(c == 'd'){
 7f8:	13490463          	beq	s2,s4,920 <vprintf+0x180>
 7fc:	f9d9079b          	addw	a5,s2,-99
 800:	0ff7f793          	zext.b	a5,a5
 804:	12fb6763          	bltu	s6,a5,932 <vprintf+0x192>
 808:	f9d9079b          	addw	a5,s2,-99
 80c:	0ff7f713          	zext.b	a4,a5
 810:	12eb6163          	bltu	s6,a4,932 <vprintf+0x192>
 814:	00271793          	sll	a5,a4,0x2
 818:	00000717          	auipc	a4,0x0
 81c:	5b070713          	add	a4,a4,1456 # dc8 <malloc+0x376>
 820:	97ba                	add	a5,a5,a4
 822:	439c                	lw	a5,0(a5)
 824:	97ba                	add	a5,a5,a4
 826:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 828:	008b8913          	add	s2,s7,8
 82c:	4685                	li	a3,1
 82e:	4629                	li	a2,10
 830:	000ba583          	lw	a1,0(s7)
 834:	8556                	mv	a0,s5
 836:	00000097          	auipc	ra,0x0
 83a:	ebe080e7          	jalr	-322(ra) # 6f4 <printint>
 83e:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 840:	4981                	li	s3,0
 842:	b745                	j	7e2 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 844:	008b8913          	add	s2,s7,8
 848:	4681                	li	a3,0
 84a:	4629                	li	a2,10
 84c:	000ba583          	lw	a1,0(s7)
 850:	8556                	mv	a0,s5
 852:	00000097          	auipc	ra,0x0
 856:	ea2080e7          	jalr	-350(ra) # 6f4 <printint>
 85a:	8bca                	mv	s7,s2
      state = 0;
 85c:	4981                	li	s3,0
 85e:	b751                	j	7e2 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 860:	008b8913          	add	s2,s7,8
 864:	4681                	li	a3,0
 866:	4641                	li	a2,16
 868:	000ba583          	lw	a1,0(s7)
 86c:	8556                	mv	a0,s5
 86e:	00000097          	auipc	ra,0x0
 872:	e86080e7          	jalr	-378(ra) # 6f4 <printint>
 876:	8bca                	mv	s7,s2
      state = 0;
 878:	4981                	li	s3,0
 87a:	b7a5                	j	7e2 <vprintf+0x42>
 87c:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 87e:	008b8c13          	add	s8,s7,8
 882:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 886:	03000593          	li	a1,48
 88a:	8556                	mv	a0,s5
 88c:	00000097          	auipc	ra,0x0
 890:	e46080e7          	jalr	-442(ra) # 6d2 <putc>
  putc(fd, 'x');
 894:	07800593          	li	a1,120
 898:	8556                	mv	a0,s5
 89a:	00000097          	auipc	ra,0x0
 89e:	e38080e7          	jalr	-456(ra) # 6d2 <putc>
 8a2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8a4:	00000b97          	auipc	s7,0x0
 8a8:	57cb8b93          	add	s7,s7,1404 # e20 <digits>
 8ac:	03c9d793          	srl	a5,s3,0x3c
 8b0:	97de                	add	a5,a5,s7
 8b2:	0007c583          	lbu	a1,0(a5)
 8b6:	8556                	mv	a0,s5
 8b8:	00000097          	auipc	ra,0x0
 8bc:	e1a080e7          	jalr	-486(ra) # 6d2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8c0:	0992                	sll	s3,s3,0x4
 8c2:	397d                	addw	s2,s2,-1
 8c4:	fe0914e3          	bnez	s2,8ac <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 8c8:	8be2                	mv	s7,s8
      state = 0;
 8ca:	4981                	li	s3,0
 8cc:	6c02                	ld	s8,0(sp)
 8ce:	bf11                	j	7e2 <vprintf+0x42>
        s = va_arg(ap, char*);
 8d0:	008b8993          	add	s3,s7,8
 8d4:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 8d8:	02090163          	beqz	s2,8fa <vprintf+0x15a>
        while(*s != 0){
 8dc:	00094583          	lbu	a1,0(s2)
 8e0:	c9a5                	beqz	a1,950 <vprintf+0x1b0>
          putc(fd, *s);
 8e2:	8556                	mv	a0,s5
 8e4:	00000097          	auipc	ra,0x0
 8e8:	dee080e7          	jalr	-530(ra) # 6d2 <putc>
          s++;
 8ec:	0905                	add	s2,s2,1
        while(*s != 0){
 8ee:	00094583          	lbu	a1,0(s2)
 8f2:	f9e5                	bnez	a1,8e2 <vprintf+0x142>
        s = va_arg(ap, char*);
 8f4:	8bce                	mv	s7,s3
      state = 0;
 8f6:	4981                	li	s3,0
 8f8:	b5ed                	j	7e2 <vprintf+0x42>
          s = "(null)";
 8fa:	00000917          	auipc	s2,0x0
 8fe:	4c690913          	add	s2,s2,1222 # dc0 <malloc+0x36e>
        while(*s != 0){
 902:	02800593          	li	a1,40
 906:	bff1                	j	8e2 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 908:	008b8913          	add	s2,s7,8
 90c:	000bc583          	lbu	a1,0(s7)
 910:	8556                	mv	a0,s5
 912:	00000097          	auipc	ra,0x0
 916:	dc0080e7          	jalr	-576(ra) # 6d2 <putc>
 91a:	8bca                	mv	s7,s2
      state = 0;
 91c:	4981                	li	s3,0
 91e:	b5d1                	j	7e2 <vprintf+0x42>
        putc(fd, c);
 920:	02500593          	li	a1,37
 924:	8556                	mv	a0,s5
 926:	00000097          	auipc	ra,0x0
 92a:	dac080e7          	jalr	-596(ra) # 6d2 <putc>
      state = 0;
 92e:	4981                	li	s3,0
 930:	bd4d                	j	7e2 <vprintf+0x42>
        putc(fd, '%');
 932:	02500593          	li	a1,37
 936:	8556                	mv	a0,s5
 938:	00000097          	auipc	ra,0x0
 93c:	d9a080e7          	jalr	-614(ra) # 6d2 <putc>
        putc(fd, c);
 940:	85ca                	mv	a1,s2
 942:	8556                	mv	a0,s5
 944:	00000097          	auipc	ra,0x0
 948:	d8e080e7          	jalr	-626(ra) # 6d2 <putc>
      state = 0;
 94c:	4981                	li	s3,0
 94e:	bd51                	j	7e2 <vprintf+0x42>
        s = va_arg(ap, char*);
 950:	8bce                	mv	s7,s3
      state = 0;
 952:	4981                	li	s3,0
 954:	b579                	j	7e2 <vprintf+0x42>
 956:	74e2                	ld	s1,56(sp)
 958:	79a2                	ld	s3,40(sp)
 95a:	7a02                	ld	s4,32(sp)
 95c:	6ae2                	ld	s5,24(sp)
 95e:	6b42                	ld	s6,16(sp)
 960:	6ba2                	ld	s7,8(sp)
    }
  }
}
 962:	60a6                	ld	ra,72(sp)
 964:	6406                	ld	s0,64(sp)
 966:	7942                	ld	s2,48(sp)
 968:	6161                	add	sp,sp,80
 96a:	8082                	ret

000000000000096c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 96c:	715d                	add	sp,sp,-80
 96e:	ec06                	sd	ra,24(sp)
 970:	e822                	sd	s0,16(sp)
 972:	1000                	add	s0,sp,32
 974:	e010                	sd	a2,0(s0)
 976:	e414                	sd	a3,8(s0)
 978:	e818                	sd	a4,16(s0)
 97a:	ec1c                	sd	a5,24(s0)
 97c:	03043023          	sd	a6,32(s0)
 980:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 984:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 988:	8622                	mv	a2,s0
 98a:	00000097          	auipc	ra,0x0
 98e:	e16080e7          	jalr	-490(ra) # 7a0 <vprintf>
}
 992:	60e2                	ld	ra,24(sp)
 994:	6442                	ld	s0,16(sp)
 996:	6161                	add	sp,sp,80
 998:	8082                	ret

000000000000099a <printf>:

void
printf(const char *fmt, ...)
{
 99a:	711d                	add	sp,sp,-96
 99c:	ec06                	sd	ra,24(sp)
 99e:	e822                	sd	s0,16(sp)
 9a0:	1000                	add	s0,sp,32
 9a2:	e40c                	sd	a1,8(s0)
 9a4:	e810                	sd	a2,16(s0)
 9a6:	ec14                	sd	a3,24(s0)
 9a8:	f018                	sd	a4,32(s0)
 9aa:	f41c                	sd	a5,40(s0)
 9ac:	03043823          	sd	a6,48(s0)
 9b0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 9b4:	00840613          	add	a2,s0,8
 9b8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 9bc:	85aa                	mv	a1,a0
 9be:	4505                	li	a0,1
 9c0:	00000097          	auipc	ra,0x0
 9c4:	de0080e7          	jalr	-544(ra) # 7a0 <vprintf>
}
 9c8:	60e2                	ld	ra,24(sp)
 9ca:	6442                	ld	s0,16(sp)
 9cc:	6125                	add	sp,sp,96
 9ce:	8082                	ret

00000000000009d0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9d0:	1141                	add	sp,sp,-16
 9d2:	e422                	sd	s0,8(sp)
 9d4:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9d6:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9da:	00001797          	auipc	a5,0x1
 9de:	a867b783          	ld	a5,-1402(a5) # 1460 <freep>
 9e2:	a02d                	j	a0c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9e4:	4618                	lw	a4,8(a2)
 9e6:	9f2d                	addw	a4,a4,a1
 9e8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9ec:	6398                	ld	a4,0(a5)
 9ee:	6310                	ld	a2,0(a4)
 9f0:	a83d                	j	a2e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9f2:	ff852703          	lw	a4,-8(a0)
 9f6:	9f31                	addw	a4,a4,a2
 9f8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9fa:	ff053683          	ld	a3,-16(a0)
 9fe:	a091                	j	a42 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a00:	6398                	ld	a4,0(a5)
 a02:	00e7e463          	bltu	a5,a4,a0a <free+0x3a>
 a06:	00e6ea63          	bltu	a3,a4,a1a <free+0x4a>
{
 a0a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a0c:	fed7fae3          	bgeu	a5,a3,a00 <free+0x30>
 a10:	6398                	ld	a4,0(a5)
 a12:	00e6e463          	bltu	a3,a4,a1a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a16:	fee7eae3          	bltu	a5,a4,a0a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 a1a:	ff852583          	lw	a1,-8(a0)
 a1e:	6390                	ld	a2,0(a5)
 a20:	02059813          	sll	a6,a1,0x20
 a24:	01c85713          	srl	a4,a6,0x1c
 a28:	9736                	add	a4,a4,a3
 a2a:	fae60de3          	beq	a2,a4,9e4 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 a2e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a32:	4790                	lw	a2,8(a5)
 a34:	02061593          	sll	a1,a2,0x20
 a38:	01c5d713          	srl	a4,a1,0x1c
 a3c:	973e                	add	a4,a4,a5
 a3e:	fae68ae3          	beq	a3,a4,9f2 <free+0x22>
    p->s.ptr = bp->s.ptr;
 a42:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a44:	00001717          	auipc	a4,0x1
 a48:	a0f73e23          	sd	a5,-1508(a4) # 1460 <freep>
}
 a4c:	6422                	ld	s0,8(sp)
 a4e:	0141                	add	sp,sp,16
 a50:	8082                	ret

0000000000000a52 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a52:	7139                	add	sp,sp,-64
 a54:	fc06                	sd	ra,56(sp)
 a56:	f822                	sd	s0,48(sp)
 a58:	f426                	sd	s1,40(sp)
 a5a:	ec4e                	sd	s3,24(sp)
 a5c:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a5e:	02051493          	sll	s1,a0,0x20
 a62:	9081                	srl	s1,s1,0x20
 a64:	04bd                	add	s1,s1,15
 a66:	8091                	srl	s1,s1,0x4
 a68:	0014899b          	addw	s3,s1,1
 a6c:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 a6e:	00001517          	auipc	a0,0x1
 a72:	9f253503          	ld	a0,-1550(a0) # 1460 <freep>
 a76:	c915                	beqz	a0,aaa <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a78:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a7a:	4798                	lw	a4,8(a5)
 a7c:	08977e63          	bgeu	a4,s1,b18 <malloc+0xc6>
 a80:	f04a                	sd	s2,32(sp)
 a82:	e852                	sd	s4,16(sp)
 a84:	e456                	sd	s5,8(sp)
 a86:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a88:	8a4e                	mv	s4,s3
 a8a:	0009871b          	sext.w	a4,s3
 a8e:	6685                	lui	a3,0x1
 a90:	00d77363          	bgeu	a4,a3,a96 <malloc+0x44>
 a94:	6a05                	lui	s4,0x1
 a96:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a9a:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a9e:	00001917          	auipc	s2,0x1
 aa2:	9c290913          	add	s2,s2,-1598 # 1460 <freep>
  if(p == (char*)-1)
 aa6:	5afd                	li	s5,-1
 aa8:	a091                	j	aec <malloc+0x9a>
 aaa:	f04a                	sd	s2,32(sp)
 aac:	e852                	sd	s4,16(sp)
 aae:	e456                	sd	s5,8(sp)
 ab0:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 ab2:	00001797          	auipc	a5,0x1
 ab6:	9be78793          	add	a5,a5,-1602 # 1470 <base>
 aba:	00001717          	auipc	a4,0x1
 abe:	9af73323          	sd	a5,-1626(a4) # 1460 <freep>
 ac2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 ac4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 ac8:	b7c1                	j	a88 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 aca:	6398                	ld	a4,0(a5)
 acc:	e118                	sd	a4,0(a0)
 ace:	a08d                	j	b30 <malloc+0xde>
  hp->s.size = nu;
 ad0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 ad4:	0541                	add	a0,a0,16
 ad6:	00000097          	auipc	ra,0x0
 ada:	efa080e7          	jalr	-262(ra) # 9d0 <free>
  return freep;
 ade:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 ae2:	c13d                	beqz	a0,b48 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ae4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ae6:	4798                	lw	a4,8(a5)
 ae8:	02977463          	bgeu	a4,s1,b10 <malloc+0xbe>
    if(p == freep)
 aec:	00093703          	ld	a4,0(s2)
 af0:	853e                	mv	a0,a5
 af2:	fef719e3          	bne	a4,a5,ae4 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 af6:	8552                	mv	a0,s4
 af8:	00000097          	auipc	ra,0x0
 afc:	baa080e7          	jalr	-1110(ra) # 6a2 <sbrk>
  if(p == (char*)-1)
 b00:	fd5518e3          	bne	a0,s5,ad0 <malloc+0x7e>
        return 0;
 b04:	4501                	li	a0,0
 b06:	7902                	ld	s2,32(sp)
 b08:	6a42                	ld	s4,16(sp)
 b0a:	6aa2                	ld	s5,8(sp)
 b0c:	6b02                	ld	s6,0(sp)
 b0e:	a03d                	j	b3c <malloc+0xea>
 b10:	7902                	ld	s2,32(sp)
 b12:	6a42                	ld	s4,16(sp)
 b14:	6aa2                	ld	s5,8(sp)
 b16:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 b18:	fae489e3          	beq	s1,a4,aca <malloc+0x78>
        p->s.size -= nunits;
 b1c:	4137073b          	subw	a4,a4,s3
 b20:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b22:	02071693          	sll	a3,a4,0x20
 b26:	01c6d713          	srl	a4,a3,0x1c
 b2a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b2c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b30:	00001717          	auipc	a4,0x1
 b34:	92a73823          	sd	a0,-1744(a4) # 1460 <freep>
      return (void*)(p + 1);
 b38:	01078513          	add	a0,a5,16
  }
}
 b3c:	70e2                	ld	ra,56(sp)
 b3e:	7442                	ld	s0,48(sp)
 b40:	74a2                	ld	s1,40(sp)
 b42:	69e2                	ld	s3,24(sp)
 b44:	6121                	add	sp,sp,64
 b46:	8082                	ret
 b48:	7902                	ld	s2,32(sp)
 b4a:	6a42                	ld	s4,16(sp)
 b4c:	6aa2                	ld	s5,8(sp)
 b4e:	6b02                	ld	s6,0(sp)
 b50:	b7f5                	j	b3c <malloc+0xea>
