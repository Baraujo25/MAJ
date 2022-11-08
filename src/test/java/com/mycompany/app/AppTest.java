package com.mycompany.app;

import org.testng.Assert;
import org.testng.annotations.Test;

public class AppTest {
	
	@Test
	public void example1() {
		Assert.assertEquals(2, 3, "This test should be failed");
	}
	
	@Test
	public void example2() {
		Assert.assertEquals(2, 2);
	}
	
	@Test
	public void example3() {
		Assert.assertTrue(true, "This test should be failed");
	}
	
	@Test
	    public void example4() {
		Assert.fail("This test should be failed");
	    }

}
