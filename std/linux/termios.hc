#define	VEOF		0	/* ICANON */
#define	VEOL		1	/* ICANON */
#define	VERASE		3	/* ICANON */
#define VKILL		5	/* ICANON */
#define VINTR		8	/* ISIG */
#define VQUIT		9	/* ISIG */
#define VSUSP		10	/* ISIG */
#define VSTART		12	/* IXON, IXOFF */
#define VSTOP		13	/* IXON, IXOFF */
#define VMIN		16	/* !ICANON */
#define VTIME		17	/* !ICANON */

#define	IGNBRK		0x00000001	/* ignore BREAK condition */
#define	BRKINT		0x00000002	/* map BREAK to SIGINT */
#define	IGNPAR		0x00000004	/* ignore (discard) parity errors */
#define	PARMRK		0x00000008	/* mark parity and framing errors */
#define	INPCK		0x00000010	/* enable checking of parity errors */
#define	ISTRIP		0x00000020	/* strip 8th bit off chars */
#define	INLCR		0x00000040	/* map NL into CR */
#define	IGNCR		0x00000080	/* ignore CR */
#define	ICRNL		0x00000100	/* map CR to NL (ala CRMOD) */
#define	IXON		0x00000200	/* enable output flow control */
#define	IXOFF		0x00000400	/* enable input flow control */

#define	OPOST		0x00000001	/* enable following output processing */

#define CSIZE		0x00000300	/* character size mask */
#define CS5		    0x00000000	/* 5 bits (pseudo) */
#define CS6		    0x00000100	/* 6 bits */
#define CS7		    0x00000200	/* 7 bits */
#define CS8		    0x00000300	/* 8 bits */
#define CSTOPB		0x00000400	/* send 2 stop bits */
#define CREAD		0x00000800	/* enable receiver */
#define PARENB		0x00001000	/* parity enable */
#define PARODD		0x00002000	/* odd parity, else even */
#define HUPCL		0x00004000	/* hang up on last close */
#define CLOCAL		0x00008000	/* ignore modem status lines */

#define	ECHOE		0x00000002	/* visually erase chars */
#define	ECHOK		0x00000004	/* echo NL after line kill */
#define ECHO		0x00000008	/* enable echoing */
#define	ECHONL		0x00000010	/* echo NL even if ECHO is off */

struct termios {
    uint32	c_iflag;	/* input flags */
    uint32	c_oflag;	/* output flags */
    uint32	c_cflag;	/* control flags */
    uint32	c_lflag;	/* local flags */
    uint8   c_cc[NCCS];	/* control chars */
    int32	c_ispeed;	/* input speed */
    int32	c_ospeed;	/* output speed */
};

int ioctl(int fd, uint op, void* argp){
    @asm(rax, rdi, rsi, rdx,
    "mov rax, 16
    mov rdi, %0
    mov rsi, %1
    mov rdx, %2
    syscall
    mov [rbp+16], rax", fd, op, argp);
}

int tcgetattr(int fd, termios *term)
{
	return ioctl(fd, TCGETS, term);
}

int tcsetattr(int fd, int actions, termios* term)
{
	switch (actions) {
	case TCSANOW:
		return ioctl(fd, TCSETS , term);
	case TCSADRAIN:
		return ioctl(fd, TCSETSW, term);
	case TCSAFLUSH:
		return ioctl(fd, TCSETSF, term);
	}
	errno = EINVAL;
	return -1;
}

void cfmakeraw(termios *t)
{
	t->c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP |
			INLCR | IGNCR | ICRNL | IXON);
	t->c_oflag &= ~OPOST;
	t->c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
	t->c_cflag &= ~(CSIZE | PARENB);
	t->c_cflag |= CS8;
	t->c_cc[VMIN] = 1;
	t->c_cc[VTIME] = 0;
}
