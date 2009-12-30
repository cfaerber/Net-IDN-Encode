#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define BASE 36
#define TMIN 1
#define TMAX 26
#define SKEW 38
#define DAMP 700
#define INITIAL_BIAS 72
#define INITIAL_N 128

#define UCHAR UV

#define isBASE(x) UTF8_IS_INVARIANT((unsigned char)x)
#define DELIM '-'

#define TMIN_MAX(t)  (((t) < TMIN) ? (TMIN) : ((t) > TMAX) ? (TMAX) : (t))

static char enc_digit[BASE+10] = {
  'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
  'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 

 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',

};

static int dec_digit[0x80] = {
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, /* 00..0F */
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, /* 10..1F */
  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, /* 20..2F */
  27, 28, 29, 30, 31, 32, 33, 34, 35, 36, -1, -1, -1, -1, -1, -1, /* 30..3F */
  -1,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, /* 40..4F */
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, -1, -1, -1, -1, -1, /* 50..5F */
  -1,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, /* 60..6F */
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, -1, -1, -1, -1, -1, /* 70..7F */
};

static int adapt(int delta, int numpoints, int first) {
  int k;

  delta /= first ? DAMP : 2;
  delta += delta/numpoints;

  for(k=0; delta > ((BASE-TMIN) * TMAX)/2; k += BASE)
    delta /= BASE-TMIN;

  return k + (((BASE-TMIN+1) * delta) / (delta+SKEW));
};

MODULE = Net::IDN::Punycode PACKAGE = Net::IDN::Punycode

SV*
encode_punycode(input)
		SV * input	
	PREINIT:
		UCHAR c, m, n = INITIAL_N;
		int k, q, t;
		int bias = INITIAL_BIAS;
		int delta = 0;

		char *in_s, *in_p, *in_e, *re_s, *re_p, *re_e, skip_p;
		int first = 1;
		STRLEN h, remain;

		STRLEN length_guess, u8, skip8;

	CODE:	
		length_guess = sv_utf8_upgrade(input);

		/* copy basic code points */

		in_s = in_p = SvPV_nolen(input);
		in_e = SvEND(input);

		++length_guess;
		RETVAL = NEWSV('P',length_guess);
		SvPOK_only(RETVAL);			/* UTF8 is off */
		re_s = re_p = SvPV_nolen(RETVAL);
		re_e = re_s + length_guess;

		while(in_p < in_e) {
		  if( isBASE(*in_p) ) 
		    *re_p++ = *in_p;
		  in_p++;
		}

		h = re_p - re_s;
		remain = sv_len_utf8(input) - h;

		/* add DELIM if needed */	
		if(h) *re_p++ = DELIM;

		while( remain > 0 ) {
		  /* find smallest code point not yet handled */
		  m = UV_MAX;

		  for(in_p = in_s; in_p < in_e;) {
		    c = utf8_to_uvuni(in_p, &u8);
		    if(c >= n && c < m) m = c;
		    in_p += u8;
		  }

		  /* increase delta to the state corresponding to
		     the m code point at the beginning of the string */
		  delta += (m-n) * (h+1);
		  n = m;

		  /* now find the chars to be encoded in this round */

		  for(in_p = in_s; in_p < in_e;) {
		    c = utf8_to_uvuni(in_p, &u8);
		    
		    if(c < n) {
		      ++delta;
                    } else if( c == n ) {
		      q = delta;

		      for(k = BASE;; k += BASE) {
			if(re_p >= re_e) {
			  length_guess = re_e - re_s + 1 + remain * 3;
			  re_e = SvGROW(RETVAL, length_guess);
			  re_p = re_e + (re_p - re_s);
			  re_s = re_e;
			  re_e = re_s + length_guess;
			}

			t = TMIN_MAX(k - bias);
			if(q < t) break;
			*re_p++ = enc_digit[t + ((q-t) % (BASE-t))];
		        q = (q-t) / (BASE-t);
  		      }
	              *re_p++ = enc_digit[q];
		      bias = adapt(delta, h+1, first);
                      delta = first = 0;
		      ++h;
		      --remain;
                    }
		    in_p += u8;
		  }
		  ++delta;
		  ++n;
		}
		*re_p = 0;
		SvCUR_set(RETVAL, re_p - re_s);

	OUTPUT:
		RETVAL
