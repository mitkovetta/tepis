package tepisclient;

/**
 * Contains parameters specifying a tile from a digital slide.
 * 
 * @author Mitko Veta
 *
 */

public class ImageTileParam {
	
	
	/*
	 * Coordinates of the image tile. dir is equivalent to the digital slide level.   
	 */
	private final Integer col;
	private final Integer row;
	private final Integer dir;
	
	/**
	 * @param col
	 * @param row
	 * @param dir
	 */
	public ImageTileParam(Integer col, Integer row, Integer dir) {	
		
		this.col = col;
		this.row = row;
		this.dir = dir;
		
	}
	
	/**
	 * Returns parameters for a tile located below the current one.
	 * 
	 * @return Parameters for the new tile.
	 */
	public ImageTileParam nextCol() {
		
		return new ImageTileParam(this.col + 1, this.row, this.dir);
	}
	
	/**
	 * Returns parameters for a tile located to the right from the current
	 * one.
	 * 
	 * @return Parameters for the new tile.
	 */
	public ImageTileParam nextRow() {
		
		return new ImageTileParam(this.col, this.row + 1, this.dir);
	}
	
	/**
	 * Returns parameters for a tile with the same position located one level up
	 * from the current one.
	 * 
	 * @return Parameters for the new tile. 
	 */
	public ImageTileParam nextDir() {
		
		return new ImageTileParam(this.col, this.row, this.dir + 1);
	}
	
	/**
	 * Returns parameters for a tile located to the left from the current
	 * one.
	 * 
	 * @return Parameters for the new tile.
	 */
	public ImageTileParam prevCol() {
		
		return new ImageTileParam(this.col - 1, this.row, this.dir);
	}
	
	/**
	 * Returns parameters for a tile located above the current one.
	 * 
	 * @return Parameters for the new tile.
	 */
	public ImageTileParam prevRow() {
		
		return new ImageTileParam(this.col, this.row - 1, this.dir);
	}
	
	/**
	 * Returns parameters for a tile with the same position located one level below
	 * from the current one.
	 * 
	 * @return Parameters for the new tile.
	 */
	public ImageTileParam prevDir() {
		
		return new ImageTileParam(this.col, this.row, this.dir - 1);
	}

	/**
	 * Gets the horizontal coordinate (column) of the tile.
	 * 
	 * @return The horizontal coordinate (column).
	 */
	public Integer getCol() {
		
		return col;
	}

	/**
	 * Gets the vertical coordinate (row) of the tile.
	 * 
	 * @return The vertical coordinate (row).
	 */
	public Integer getRow() {
		
		return row;
	}

	/**
	 * Gets the level of the tile.
	 * 
	 * @return The level.
	 */
	public Integer getDir() {
		
		return dir;
	}

	@Override
	public String toString() {
		
		return "ImageTileParam [col=" + col + ", row=" + row + ", dir=" + dir
				+ "]";
	}
	
}
