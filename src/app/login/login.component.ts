import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, NavigationEnd } from '@angular/router';
import { ApiService } from '../service/api.service';
import { HttpClient } from '@angular/common/http';
@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss'
})
export class LoginComponent {
  title = 'login';
  currentRoute: string = '';
  email: string = '';
  password: string = '';

  constructor(
    private router: Router,
    private ApiService: ApiService,
    private http: HttpClient) {
    this.router.events.subscribe((event) => {
      if (event instanceof NavigationEnd) {
        this.currentRoute = event.url;
      }
    });
  }

  isRouteActive(route: string): boolean {
    return this.currentRoute === route;
  }

  login(): void {
    this.ApiService.login(this.email, this.password).subscribe(
      (response) => {
        // Obsłuż odpowiedź od serwera (np. przeniesienie na inną stronę po poprawnym logowaniu)
        console.log(response);
      },
      (error) => {
        // Obsłuż błąd logowania
        console.error('Login error:', error);
      }
    );
}
}