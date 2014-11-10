// ce_gtest_proj.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "gtest/gtest.h"
#pragma comment(linker, "/nodefaultlib:secchk.lib")
int add(int a, int b)
{
	return a+b;
}

TEST(AddTest, TestNonNegativeNumber)
{
	EXPECT_EQ(1, add(1,0));
	EXPECT_EQ(42, add(1,41));
}

int _tmain(int argc, _TCHAR* argv[])
{
	testing::InitGoogleTest(&argc, argv);
	return RUN_ALL_TESTS();
}

