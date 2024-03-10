#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{

  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64 
sys_getppid(void) {
  struct proc *current_proc = myproc(); // (1) call myproc() to get the caller’s struct proc
  if (current_proc == 0) return -1; // Return an error or invalid PID if no current process is found
  
  struct proc *parent_proc = current_proc->parent; // (2) follow the field “parent” in the struct proc to find the parent’s struct proc
  if (parent_proc == 0) return -1; // Return an error or invalid PID if no parent process is found
  
  uint64 parent_pid = parent_proc->pid; // (3) in the parent’s struct proc, find the pid and return it
  return parent_pid;
}


extern struct proc proc[NPROC]; //declare array proc which is defined in proc.c already
uint64
sys_ps(void){
  //define the ps_struct for each process and ps[NPROC] for all processes
  struct ps_struct{
    int pid;
    int ppid;
    char state[10];
    char name[16];
  }ps[NPROC];

  int numProc = 0; //variable keeping track of the number of processes in the system
  /*To do: From array proc, find the processes that are still in the system (i.e.,
  their states are not NUNUSED. For each of the process, retrieve the
  information
  and put into a ps_struct defined above*/
  // here we save the user space argument's address, to arg_addr

  static char *states[] = {
    [UNUSED]    "unused",
    [USED]      "used",
    [SLEEPING]  "sleep ",
    [RUNNABLE]  "runble",
    [RUNNING]   "run   ",
    [ZOMBIE]    "zombie"
};

for (int i = 0; i < NPROC; i++) {
  if (proc[i].state != UNUSED) {
    ps[numProc].pid = proc[i].pid;
    ps[numProc].ppid = proc[i].parent ? proc[i].parent->pid : -1; // Assuming parent is a pointer to the parent proc struct
    // Correctly map the numeric state to its string representation
    if(proc[i].state >= 0 && proc[i].state < NELEM(states) && states[proc[i].state]) {
        strncpy(ps[numProc].state, states[proc[i].state], sizeof(ps[numProc].state) - 1);
        ps[numProc].state[sizeof(ps[numProc].state) - 1] = '\0'; // Ensure null-termination
    } else {
        strncpy(ps[numProc].state, "???", sizeof(ps[numProc].state) - 1);
        ps[numProc].state[sizeof(ps[numProc].state) - 1] = '\0'; // Ensure null-termination for safety
    }

    strncpy(ps[numProc].name, proc[i].name, sizeof(ps[numProc].name) - 1);
    ps[numProc].name[sizeof(ps[numProc].name) - 1] = '\0'; // Ensure null-termination for the name as well

    numProc++;
  }
}


  uint64 arg_addr;
  argaddr(0, &arg_addr);
  //copy array ps to the saved address
  if (copyout(myproc()->pagetable,
  arg_addr,
  (char *)ps,
  numProc*sizeof(struct ps_struct)) < 0)
  return -1;
  //return numProc as well
  return numProc;
}

uint64
sys_getschedhistory(void){
 


  struct sched_history{
    int runCount;
    int systemcallCount;
    int interruptCount;
    int preemptCount;
    int trapCount;
    int sleepCount;
  } my_history;


  // Retrieve the current process's information
  struct proc *p = myproc();
  if (p == 0) return -1; // Error if no current process

  // Populate my_history with the current process's scheduling history
  my_history.runCount = p->runCount;
  my_history.systemcallCount = p->systemcallCount;
  my_history.interruptCount = p->interruptCount;
  my_history.preemptCount = p->preemptCount;
  my_history.trapCount = p->trapCount;
  my_history.sleepCount = p->sleepCount;

  // Save the address of the user space argument to arg_addr
  uint64 arg_addr;
  argaddr(0, &arg_addr);



  // copy my_history's content to the address we have savedd
  if (copyout(p->pagetable, arg_addr, (char *)&my_history, sizeof(struct sched_history)) < 0)
    return -1;

  // this is if when it's been copied successfully and we return the pid
  return p->pid; 
}

