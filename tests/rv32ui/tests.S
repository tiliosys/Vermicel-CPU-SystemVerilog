#define TEST(n) \
	.global n; \
	jal zero,n; \
	.global n ## _ret; \
	n ## _ret:

    .global main
main:
    TEST(lui)
	TEST(auipc)
	TEST(j)
	TEST(jal)
	TEST(jalr)

	TEST(beq)
	TEST(bne)
	TEST(blt)
	TEST(bge)
	TEST(bltu)
	TEST(bgeu)

	TEST(lb)
	TEST(lh)
	TEST(lw)
	TEST(lbu)
	TEST(lhu)

	TEST(sb)
	TEST(sh)
	TEST(sw)

	TEST(addi)
	TEST(slti) // also tests sltiu
	TEST(xori)
	TEST(ori)
	TEST(andi)
	TEST(slli)
	TEST(srli)
	TEST(srai)

	TEST(add)
	TEST(sub)
	TEST(sll)
	TEST(slt) // what is with sltu ?
	TEST(xor)
	TEST(srl)
	TEST(sra)
	TEST(or)
	TEST(and)
/*
	TEST(mulh)
	TEST(mulhsu)
	TEST(mulhu)
	TEST(mul)

	TEST(div)
	TEST(divu)
	TEST(rem)
	TEST(remu)

	TEST(simple)
*/
    j .

