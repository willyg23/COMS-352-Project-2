#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define MAX_NUM_RECEIVERS 10
#define MAX_MSG_SIZE 256
struct msg_t {
    int target; // Add target child ID
    char content[MAX_MSG_SIZE];
};

void panic(char *s) {
    fprintf(2, "%s\n", s);
    exit(1);
}

int fork1(void) {
    int pid = fork();
    if(pid == -1)
        panic("fork");
    return pid;
}

void pipe1(int fd[2]) {
    if(pipe(fd) < 0) {
        panic("Fail to create a pipe.");
    }
}

int main(int argc, char *argv[]) {
    if(argc < 4) {
        panic("Usage: unicast <num_of_children> <target_child> <msg>");
    }

    int numChildren = atoi(argv[1]);
    int targetChild = atoi(argv[2]);
    struct msg_t msg;
    msg.target = targetChild; // Set target child ID
    strcpy(msg.content, argv[3]);

    int channelToChildren[2], channelFromChild[2];
    pipe1(channelToChildren);
    pipe1(channelFromChild);

    for(int i = 0; i < numChildren; i++) {
        int retFork = fork1();
        if(retFork == 0) { // Child process
            printf("Child %d: start!\n", i);
            read(channelToChildren[0], &msg, sizeof(msg));

            if(i == msg.target) {
                printf("Child %d: get msg (%s) to Child %d\n", i, msg.content, msg.target);
                printf("Child %d: the msg is for me.\n", i);
                write(channelFromChild[1], "received!", 10);
            } else {
                printf("Child %d: get msg (%s) to Child %d\n", i, msg.content, msg.target);
                printf("Child %d: the msg is not for me.\n", i);
                printf("Child %d: write the msg back to pipe.\n", i);
                write(channelToChildren[1], &msg, sizeof(msg)); // Pass the message along
            }
            exit(0);
        } else {
            printf("Parent: creates child process with id: %d\n", i);
        }
        sleep(1); // Ensure orderly startup
    }

    // Parent sends message to the first child
    write(channelToChildren[1], &msg, sizeof(msg));
    printf("Parent sends to Child %d: %s\n", targetChild, msg.content);

    char recvBuf[20]; // Buffer for acknowledgment
    read(channelFromChild[0], &recvBuf, sizeof(recvBuf));
    printf("Parent receives: %s\n", recvBuf);

    exit(0);
}
