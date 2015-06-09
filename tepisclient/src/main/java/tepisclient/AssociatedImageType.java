package tepisclient;

/**
 * Enumeration for associated image types.
 * 
 * @author Mitko Veta
 *
 */

public enum AssociatedImageType {
	
	LABEL("label"),
	MACRO("macro"),
	THUMBNAIL("thumbnail");
	
	private String type;

	private AssociatedImageType(String type) {

		this.type = type;		
	}

	@Override
	public String toString() {

		return type;
	}

}
