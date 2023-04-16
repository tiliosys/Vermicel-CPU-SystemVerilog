
TESTS=addi add sub slti slt \
	  andi and ori or xori xor \
	  slli sll srai sra srli srl \
	  auipc lui \
	  beq bge bgeu blt bltu bne \
	  jalr jal j \
	  lb lbu lh lhu lw sb sh sw

TESTS_RV32IM=$(TESTS) \
			 mulh mulhsu mulhu mul \
			 div divu rem remu

ASM_DEPS=$(addsuffix .S,$(TESTS))

C_FLAGS_USER=-DTEST_FUNC_NAME=$(notdir $(basename $<)) \
			 -DTEST_FUNC_TXT='"$(notdir $(basename $<))"' \
			 -DTEST_FUNC_RET=$(notdir $(basename $<))_ret

LD_SCRIPT = tests.ld

include ../../scripts/rules.mk

