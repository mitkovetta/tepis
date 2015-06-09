package tepisclient;

/**
 * Enumeration for units.
 * 
 * @author Mitko Veta
 *  
 */

public enum Unit {	
	
	MM("mm"),
	UM("um"),
	PIXEL("pixel");

	private String unit;

	private Unit(String unit) {

		this.unit = unit;		
	}

	@Override
	public String toString() {

		return unit;
	}
}
