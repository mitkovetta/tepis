package tepisclient;

import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.NewCookie;

import javax.ws.rs.client.ClientRequestFilter;
import javax.ws.rs.client.ClientRequestContext;
import javax.ws.rs.client.ClientResponseFilter;
import javax.ws.rs.client.ClientResponseContext;

/**
 * Authentication filter for the Jersey Client API.
 * <p>
 * Manages the storing and passing of the authentication cookie.
 * 
 * @author Mitko Veta
 * 
 */

public class AuthenticationFilter implements ClientRequestFilter,
		ClientResponseFilter {

	/**
	 * The authentication cookie.
	 */
	private NewCookie authCookie;

	@Override
	public void filter(ClientRequestContext requestContext) {

		if (this.authCookie != null) {
			requestContext.getHeaders()
					.add(HttpHeaders.COOKIE, this.authCookie);
		}

	}

	@Override
	public void filter(ClientRequestContext requestContext,
			ClientResponseContext responseContext) {

		if (responseContext.getCookies().get(".AuthCookie") != null) {
			this.authCookie = responseContext.getCookies().get(".AuthCookie");
		}

	}

}
