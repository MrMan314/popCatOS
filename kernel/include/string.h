#ifndef INCLUDE_STRING_H
#define INCLUDE_STRING_H
#endif

// Gets the length of a string
uint32 lenstr(char*s) {
	uint32 len=0;
	while(*s++ != 0) {
		len++;
	}return len;
}

// Reverses a string
char* revstr(char*s, uint32 len) {
	char ch;uint32 i,j;
	for(i=0,j=len-1;i<j;i++,j--) {
		ch = s[i];
		s[i] = s[j];
		s[j] = ch;
	}
	return s;
}

// Converts Integers to string
char* inttostr(int n) {
	char g[10];
	for(int i=0;i<10;i++){
		g[i]=0;
	}
	int i=0;
	bool neg = false;
	if(n < 0) {
		neg = true;
		n=-n;
	}

	do {
		g[i++] = n%10+'0';
	} while((n /= 10) > 0);

	if(neg)g[i++]='-';
	return revstr(g, i);
}

// Compares strings (0 means equal, anything else means differ)
int strcmp(const char* a, const char*b){
	while((*a==*b)&&*a){
		++a;
		++b;
	}
	return ((int) (unsigned char) *a)-((int) (unsigned char) *b);
}
