#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

//define the format of a msg
#define MAX_NUM_RECEIVERS 10
#define MAX_MSG_SIZE 256

struct msg_t{
    int flags[MAX_NUM_RECEIVERS];
    char content[MAX_MSG_SIZE];
};


void
panic(char *s)
{
  fprintf(2, "%s\n", s);
  exit(1);
}

//create a new process
int
fork1(void)
{
  int pid;
  pid = fork();
  if(pid == -1)
    panic("fork");
  return pid;
}

//create a pipe
void
pipe1(int fd[2])
{
 int rc = pipe(fd);
 if(rc<0){
   panic("Fail to create a pipe.");
 }
}

int getppid(void);

int ps(char *psinfo);

int getschedhistory(char *history);

int main(int argc, char *argv[])
{
    if(argc<3){
        panic("Usage: broadcast <num_of_receivers> <msg_to_broadcast>");
    }

    int numReceiver = atoi(argv[1]);
    
    //create a pair of pipes as communication channels
    int channelToReceivers[2], channelFromReceivers[2];
    pipe(channelToReceivers);
    pipe(channelFromReceivers);
    
    for(int i=0; i<numReceiver; i++){
        
        //create child process as receiver
        int retFork = fork1();
        if(retFork==0){

            /*following is the code for child process i*/

            //announce start of the child process 
	    int myId = i;
            printf("Child %d: start!\n", myId);

        //to fake some computation workload for Project 1.B
	    float x=12345678.0;
	    for(int i=0; i<12345678; i++)
		    for(int j=0; j<100; j++)
			    x=x*x;	
            
	    //read pipe to get the message
	    struct msg_t msg;
            read(channelToReceivers[0], 
                        (void *)&msg, sizeof(struct msg_t));
            printf("Child %d: get msg (%s)\n", 
                    myId, msg.content);

	    //check if all receivers have already received this message
            msg.flags[i]=0;
            int sum=0;
            for(int j=0; j<MAX_NUM_RECEIVERS; j++)
                    sum += msg.flags[j];
            if(sum==0){
	    	//if all receivers have received the message, send ack to parent
                write(channelFromReceivers[1],"completed!",10);    
            }else{
	    	//otherwise, write the message back to the pipe for the receivers 
		//yet to receive the mssage
                write(channelToReceivers[1],&msg,sizeof(msg));
            }

	    //end of the child process
            exit(0);
		

        }else{
            printf("Parent: creates child process with id: %d\n", i);
        }
        sleep(1);
    }

    /*following is the parent's code*/
    
    //to fake some computation workload for Project 1.B
    float x=123456.0;
    for(int i=0; i<12345678; i++)
	    for(int j=0; j<100; j++) 
		    x=x*x;

    //to broadcast message
    struct msg_t msg;
    for(int i=0; i<numReceiver; i++)
        msg.flags[i] = 1;
    strcpy(msg.content, argv[2]);
    write(channelToReceivers[1], &msg, sizeof(struct msg_t));
    printf("Parent broadcasts: %s\n", msg.content);

    //to receive acknowledgement
    char recvBuf[sizeof(struct msg_t)];        
    read(channelFromReceivers[0], &recvBuf, sizeof(struct msg_t));
    printf("Parent receives: %s\n", recvBuf);

    //call the new system calls for Project 1.B
    printf("\nCall system calls for Project 1.B\n\n");

    printf("Result from calling getppid:\n");
    int ppid = getppid();
    printf("My ppid = %d\n", ppid);

    printf("\nResult from calling ps:\n");
    int ret;
    struct ps_struct myPS[64];
    ret = ps((char *)&myPS);
    printf("Total number of processes: %d\n", ret);
    for(int i=0; i<ret; i++){
        printf("pid: %d, ppid: %d, state: %s, name: %s\n",
        myPS[i].pid, myPS[i].ppid, myPS[i].state, myPS[i].name);
    }

    printf("\nResult from calling getschedhistory:\n");
    struct sched_history myHistory;
    ret = getschedhistory((char *)&myHistory);
    printf("My scheduling history\n pid: %d\n runs: %d, traps: %d, interrupts: %d, preemptions: %d, sleeps: %d, system calls: %d\n",
        ret, myHistory.runCount, myHistory.trapCount, myHistory.interruptCount,
        myHistory.preemptCount, myHistory.sleepCount, myHistory.systemcallCount);

    //end of parent process 
    exit(0);
}
